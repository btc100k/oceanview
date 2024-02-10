//
//  Int+Formatting.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import Foundation

extension Int {
	func dateString() -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(self))
		return Utilities.dateFormatter.string(from: date)
	}

	func monthlyDateString() -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(self))
		return Utilities.monthlyFormatter.string(from: date)
	}
}
