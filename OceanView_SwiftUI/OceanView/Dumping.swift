//
//  Dumping.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftSoup
import Foundation

struct BlockEarning: Decodable {
	var blockHash: String
	var btcEarned: Double
	var btcFee: Double

	// secondary information, retrieved by networking
	var height: Int = 0
	var timestamp: Int = 0
	var btcusd: Double = 0

	init(hash: String, earned: Double, fee: Double) {
		blockHash = hash
		btcEarned = earned
		btcFee = fee
	}
}

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

	func populate(oceanAddress addr: AddressEarnings, page num: Int = 0) async throws {
		let address = await addr.address()
		let url = URL(string: "https://ocean.xyz/stats/\(address)?epage=\(num)")!
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}
		do {
			let html = String(data: data, encoding: .utf8)!
			let doc: Document = try SwiftSoup.parse(html)
			guard let earningsTable = try doc.select("#earnings-fulltable table").first() else {
				// at this point we are complete
				return
			}

			let rows = try earningsTable.select("tr")
			let rowArray = rows.array()
			for row in rowArray {
				let cells = try row.select("td").array().map { try $0.text() }

				if !cells.isEmpty {
					let blockHash = cells[0]
					let btcEarned = Double(cells[2].split(separator: " ")[0]) ?? 0.0
					let btcFee = Double(cells[3].split(separator: " ")[0]) ?? 0.0

					let earnings = BlockEarning(hash: blockHash, earned: btcEarned, fee: btcFee)
					await addr.add(earning: earnings)

					try await updateBlockHeight(oceanAddress: addr, blockHash: blockHash)
					try await updatePrice(oceanAddress: addr, blockHash: blockHash)
				}
			}
			// move on to the next page
			try await populate(oceanAddress: addr, page: num + 1)
		} catch Exception.Error(let type, let message) {
			print("Error of type \(type) with message: \(message)")
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
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
		let yyyymmdd_str = dateFormatter.string(from: date)

		let url = URL(string: "https://api.coinbase.com/v2/prices/BTC-USD/spot?date=\(yyyymmdd_str)")!

		let (rawData, response) = try await URLSession.shared.data(from: url)
		guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
			throw URLError(.badServerResponse)
		}
		do {
			//{"data":{"amount":"42126.55","base":"BTC","currency":"USD"}}
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
