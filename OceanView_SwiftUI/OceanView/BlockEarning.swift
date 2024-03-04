//
//  BlockEarning.swift
//  OceanView
//
//  Created by Raymond on 2/21/24.
//

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

	init(hash: String, earned: Double, fee: Double, ht: Int, ts: Int, usd: Double) {
		blockHash = hash
		btcEarned = earned
		btcFee = fee
		height = ht
		timestamp = ts
		btcusd = usd
	}
}
