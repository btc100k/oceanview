//
//  OceanViewApp.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import BackgroundTasks
import SwiftUI
import SwiftData
import UserNotifications

protocol AddressStorage {
	func saveOceanAddress(_ addr: String?)
	func oceanAddress() -> String?
}

protocol RefreshStorage {
	func saveRefreshFrequency(_ secondds: Int)
	func refreshFrequency() -> Int
}

protocol LocalStorage {
	func deleteEarnings() async
	func replace(earnings: [OceanEarning]) async
}

@main
struct OceanViewApp: App, AddressStorage, RefreshStorage, LocalStorage {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.scenePhase) private var phase
	@Query private var items: [OceanEarning]

	func saveRefreshFrequency(_ seconds: Int) {
		UserDefaults.standard.set(seconds, forKey: "OceanRefreshFrequencySeconds")
		UserDefaults.standard.synchronize()
	}

	func refreshFrequency() -> Int {
		UserDefaults.standard.integer(forKey: "OceanRefreshFrequencySeconds")
	}

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
				ContentView(addressStorage: self, localStorage: self, refreshStorage: self)
			} else {
				AddressView(addressStorage: self)
			}
        }
        .modelContainer(sharedModelContainer)
		.onChange(of: phase) {
			switch phase {
			case .background: scheduleAppRefresh()
			case .active: cancelAppRefresh()
			default: break
			}
		}
		.backgroundTask(.appRefresh("refresh-earnings")) {
			let countBefore = items.count
			let d = Dumping(oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa");
			await d.refresh()
			let allEarnings = await d.allOceanEarnings()
			if allEarnings.count > countBefore {
				// the # has changed
				await replace(earnings: allEarnings)
				scheduleNotification()
			}
		}
    }

	private func cancelAppRefresh() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
	}

	private func scheduleAppRefresh() {
		cancelAppRefresh()
		let frequency = refreshFrequency()
		// no way to set a refresh < 5 minutes.
		if frequency >= 60 {
			let request = BGAppRefreshTaskRequest(identifier: "refresh-earnings")
			request.earliestBeginDate = .now.addingTimeInterval(TimeInterval(frequency))
			try? BGTaskScheduler.shared.submit(request)
		}
	}

	func deleteEarnings() async {
		for removeMe in items {
			modelContext.delete(removeMe)
		}
		do {
			try modelContext.save()
		} catch {
			print("Error saving context after deletes: \(error)")
		}
	}

	func replace(earnings: [OceanEarning]) async {
		await deleteEarnings()
		for one in earnings {
			modelContext.insert(one)
		}
		do {
			try modelContext.save()
		} catch {
			print("Error saving context after insert: \(error)")
		}
	}

	func scheduleNotification() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			if granted && error == nil {
				// Create content
				let content = UNMutableNotificationContent()
				let addr = oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
				let body = "A new BTC reward has been earned by \(addr)."
				content.title = "BTC Earned"
				content.body = body
				content.sound = UNNotificationSound.default

				// Trigger
				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 5 seconds from now

				// Create the request
				let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

				// Schedule the notification
				UNUserNotificationCenter.current().add(request) { error in
					if let error = error {
						print("Error scheduling notification: \(error)")
					}
				}
			}
		}
	}

}
