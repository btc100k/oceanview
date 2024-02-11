//
//  SettingsStorage.swift
//  OceanView
//
//  Created by Raymond on 2/11/24.
//

import SwiftUI

protocol SettingsStorage {
	func saveRefreshFrequency(_ secondds: Int)
	func refreshFrequency() -> Int
	func saveNotificationUrgency(_ urgent: Bool)
	func notificationUrgency() -> Bool
}
