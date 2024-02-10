//
//  Item.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import Foundation
import SwiftData

extension Double {
	func asBTC() -> String {
		return String(format: "%0.8f", self)
	}
}

@Model
final class OceanEarning {
	var blockHash: String
	var btcEarned: Double
	var btcFee: Double
	var height: Int = 0
	var timestamp: Int = 0
	var btcusd: Double = 0

    init(earning: BlockEarning) {
		self.blockHash = earning.blockHash
		self.btcEarned = earning.btcEarned
		self.btcFee = earning.btcFee
		self.height = earning.height
		self.timestamp = earning.timestamp
		self.btcusd = earning.btcusd
    }
}
