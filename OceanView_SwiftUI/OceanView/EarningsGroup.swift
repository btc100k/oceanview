//
//  EarningsGroup.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import SwiftUI

struct EarningsGroup: Hashable {
	let month: String
	var btcTotal: Double = 0
	var usdTotal: Double = 0
	var usdAverage: Double = 0
	var earnings: [OceanEarning]

	func hash(into hasher: inout Hasher) {
		hasher.combine(month)
	}

	static func ==(lhs: EarningsGroup, rhs: EarningsGroup) -> Bool {
		lhs.month == rhs.month
	}
}
