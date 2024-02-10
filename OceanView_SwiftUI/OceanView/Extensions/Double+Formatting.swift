//
//  Double+Formatting.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import Foundation

extension Double {
	func usdString() -> String {
		return Utilities.currencyFormatter.string(from: NSNumber(value: self)) ?? "$0.00"
	}

	func asBTC() -> String {
		return String(format: "%0.8f", self)
	}
}
