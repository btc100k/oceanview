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

@main
struct OceanViewApp: App, AddressStorage, SettingsStorage, LocalStorage {
	@Environment(\.scenePhase) private var phase

	func saveNotificationUrgency(_ urgent: Bool) {
		UserDefaults.standard.set(urgent, forKey: "OceanNotificationUrgency")
		UserDefaults.standard.synchronize()
	}

	func notificationUrgency() -> Bool {
		UserDefaults.standard.bool(forKey: "OceanNotificationUrgency")
	}

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
			let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
			return container
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

	@State private var hasOceanAddress = OceanViewApp.oceanAddress() != nil

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
				ContentView(addressStorage: self, localStorage: self, settingsStorage: self)

			} else {
				AddressView(addressStorage: self)
			}
		}
		.modelContainer(sharedModelContainer)
		.onChange(of: phase) {
			switch phase {
			case .background: scheduleAppRefresh(cancel: true)
			case .active: cancelBackgroundWork()
			default: break
			}
		}
		.backgroundTask(.appRefresh("refresh-earnings")) {
			if hasOceanAddress {
				let context = ModelContext(sharedModelContainer)
				let countBefore = (try? context.fetchCount(FetchDescriptor<OceanEarning>())) ?? 0
				let d = Dumping(oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa")
				await d.refresh()
				let allEarnings = await d.allEarnings()
				if allEarnings.count > countBefore {
					// the # has changed
					await replace(earnings: allEarnings)
					scheduleNotification()
				}
				// no that we have processed this app-refresh, let us schedule the next one.
				scheduleAppRefresh(cancel: false)
			}
		}
	}

	private func cancelBackgroundWork() {
		BGTaskScheduler.shared.cancelAllTaskRequests()
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		UNUserNotificationCenter.current().setBadgeCount(0)
	}

	private func scheduleAppRefresh(cancel: Bool) {
		if cancel {
			cancelBackgroundWork()
		}
		let frequency = refreshFrequency()
		// no way to set a refresh < 5 minutes.
		if frequency >= (5*60) {
			let request = BGAppRefreshTaskRequest(identifier: "refresh-earnings")
			request.earliestBeginDate = .now.addingTimeInterval(TimeInterval(frequency))

			do {
				try BGTaskScheduler.shared.submit(request)
			} catch {
				NSLog("Failed Requested BGAppRefresh: \(error)");
			}
		}
	}

	func deleteEarnings() async {
		let context = ModelContext(sharedModelContainer)
		if let items = try? context.fetch(FetchDescriptor<OceanEarning>()) {
			for one in items {
				context.delete(one)
			}
			try? context.save()
		}
	}

	func replace(earnings: [BlockEarning]) async {
		await deleteEarnings()
		let context = ModelContext(sharedModelContainer)
		for one in earnings {
			let oneOcean = OceanEarning(earning: one)
			context.insert(oneOcean)
		}
		try? context.save()
	}

	func scheduleNotification() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			if granted && error == nil {
				// Create content
				let content = UNMutableNotificationContent()
				content.title = "BTC Earned"
				content.body = "A new BTC reward has been earned"
				content.subtitle = oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa"
				content.sound = UNNotificationSound.default
				content.badge = 1
				content.interruptionLevel = notificationUrgency() ? .active : .passive
				content.threadIdentifier = "new-block"

				let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
				let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

				// get rid of any pending notifications since we're adding a new one right now
				UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

				UNUserNotificationCenter.current().add(request) { error in
					if let error = error {
						print("Error scheduling notification: \(error)")
					}
				}
			}
		}
	}
}
