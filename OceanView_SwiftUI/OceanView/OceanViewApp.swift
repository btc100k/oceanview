//
//  OceanViewApp.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI
import SwiftData

protocol AddressStorage {
	func saveOceanAddress(_ addr: String?)
	func oceanAddress() -> String?
}

@main
struct OceanViewApp: App, AddressStorage {
	func oceanAddress() -> String? {
		OceanViewApp.oceanAddress()
	}
	
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            OceanEarning.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

	static public func oceanBlue() -> Color {
		Color(red: 34/255, green: 58/255, blue: 245/255)
	}

	static public func oceanAddress() -> String? {
		UserDefaults.standard.string(forKey: "OceanAddress")
	}
	@State public var hasOceanAddress = OceanViewApp.oceanAddress() != nil

	public func saveOceanAddress(_ addr: String?) {
		if let address = addr {
			UserDefaults.standard.set(address, forKey: "OceanAddress")
			UserDefaults.standard.synchronize()
			hasOceanAddress = true
		} else {
			UserDefaults.standard.removeObject(forKey: "OceanAddress")
			UserDefaults.standard.synchronize()
			hasOceanAddress = false
		}
	}

    var body: some Scene {
        WindowGroup {
			if hasOceanAddress {
				ContentView(addressStorage: self)
			} else {
				AddressView(addressStorage: self)
			}
        }
        .modelContainer(sharedModelContainer)
    }
}
