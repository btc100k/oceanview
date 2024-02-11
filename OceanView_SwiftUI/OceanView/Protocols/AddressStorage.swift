//
//  AddressStorage.swift
//  OceanView
//
//  Created by Raymond on 2/11/24.
//

import SwiftUI

protocol AddressStorage {
	func saveOceanAddress(_ addr: String?)
	func oceanAddress() -> String?
}

