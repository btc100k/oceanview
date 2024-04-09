//
//  Dumping.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import Foundation


actor AddressEarnings {
	private var results: [String:BlockEarning] = [:]
	private let oceanAddress: String

	init(addr: String = "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa") {
		oceanAddress = addr
	}

	func add(earning: BlockEarning) async {
		results[earning.blockHash] = earning
	}

	func earnings() async -> [BlockEarning] {
		Array(results.values)
	}

	func address() async -> String {
		oceanAddress
	}

	func blockEarning(hash: String) async -> BlockEarning? {
		results[hash]
	}

	func update(hash: String, height: Int, timestamp: Int) async {
		guard var earning =  results[hash] else {
			return
		}
		earning.height = height
		earning.timestamp = timestamp
		results[hash] = earning
	}

	func update(hash: String, btcusd: Double) async {
		guard var earning =  results[hash] else {
			return
		}
		earning.btcusd = btcusd
		results[hash] = earning
	}
}

class Dumping {
	let earnings: AddressEarnings

	init(_ address: String) {
		earnings = AddressEarnings(addr: address)
	}

	func allEarnings() async -> [BlockEarning] {
		await earnings.earnings()
	}

	func refresh() async {
		do {
			try await populate(oceanAddress: earnings)
		} catch {
			print("Error: \(error)")
		}
	}

	//https://api.ocean.xyz/v1/earnpay/bc1q6w0n6mjcq56t45fk7slveqw0n0ss7flsfj5uh8
	func populate(oceanAddress addr: AddressEarnings) async throws {
		let address = await addr.address()
		let url = URL(string: "https://api.ocean.xyz/v1/earnpay/\(address)/1701388800/99999999999")!
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}
		do {
			let decoder = JSONDecoder()
			let response = try decoder.decode(EarnPayRoot.self, from: data)
			
			let rowArray = response.result.earnings
			for row in rowArray {
				/*
				 let blockHash: String
				 let ts: String
				 let sharesInWindow: Int
				 let feesCollectedSatoshis: Int
				 let satoshisNetEarned: Int
				 
				 */
				let blockHash = row.blockHash
				let btcEarned = Double(row.satoshisNetEarned) / 100_000_000.0
				let btcFee = Double(row.feesCollectedSatoshis) / 100_000_000.0
				
				let earnings = BlockEarning(hash: blockHash, earned: btcEarned, fee: btcFee)
				await addr.add(earning: earnings)
				
				try await updateBlockHeight(oceanAddress: addr, blockHash: blockHash)
				try await updatePrice(oceanAddress: addr, blockHash: blockHash)
			}
		} catch {
			print("error")
		}
	}

	func updateBlockHeight(oceanAddress addr: AddressEarnings, blockHash: String) async throws {
		let url = URL(string: "https://mempool.space/api/block/\(blockHash)")!

		URLSession.shared.dataTask(with: url)
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}

		do {
			guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
				print("JSON decode failure - \(url)")
				return
			}
			guard let timestamp = jsonObject["timestamp"] as? Int else {
				print("JSON - missing timestamp")
				return
			}
			guard let height = jsonObject["height"] as? Int else {
				print("JSON - missing height")
				return
			}

			await addr.update(hash: blockHash, height: height, timestamp: timestamp)

		} catch {
			throw URLError(.badServerResponse, userInfo:["blockHash": blockHash, "context": "updateBlockHeight"])
		}
	}


	func updatePrice(oceanAddress addr: AddressEarnings, blockHash: String) async throws {
		guard let blockEarning = await addr.blockEarning(hash: blockHash) else {
			//no known block
			return
		}
		if blockEarning.timestamp == 0 {
			return
		}
		let date = Date(timeIntervalSince1970: TimeInterval(blockEarning.timestamp))
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		let yyyymmdd_str = dateFormatter.string(from: date)

		let url = URL(string: "https://api.coinbase.com/v2/prices/BTC-USD/spot?date=\(yyyymmdd_str)")!

		let (rawData, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}
		do {
			guard let jsonObject = try JSONSerialization.jsonObject(with: rawData, options: []) as? [String: Any] else {
				print("JSON decode failure \(url)")
				return
			}
			guard let dataElem = jsonObject["data"] as? [String: Any] else {
				print("JSON - missing data amount")
				return
			}
			guard let priceAsStr = dataElem["amount"] as? String, let price = Double(priceAsStr) else {
				print("JSON - missing BTCUSD amount")
				return
			}
			await addr.update(hash: blockHash, btcusd: price)

		} catch {
			throw URLError(.badServerResponse, userInfo:["blockHash": blockHash, "context": "updatePrice"])
		}
	}
}
