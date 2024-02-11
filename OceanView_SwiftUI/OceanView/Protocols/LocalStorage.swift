//
//  LocalStorage.swift
//  OceanView
//
//  Created by Raymond on 2/11/24.
//

import SwiftUI

protocol LocalStorage {
	func deleteEarnings() async
	func replace(earnings: [BlockEarning]) async
}
