//
//  ContentSettingsView.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import SwiftUI

struct ContentSettingsView: View {
	@State private var selectedRefreshInterval = 0
	@State private var notificationUrgency = 0
	@State private var copyingToClipboard: Bool = false
	let settingsStorage: SettingsStorage?
	let refreshIntervals = [("Manual Only", 0),
							("5 minutes", 300),
							("15 minutes", 900),
							("1 hour", 3600),
							("6 hours", 21600),
							("12 hours", 43200),
							("24 hours", 86400),
							("48 hours", 172800),
	]
	let urgencyMenu = [("Low Priority", 0),
					   ("High Priority", 1),
	]

	init(settingsStorage sStorage: SettingsStorage?) {
		settingsStorage = sStorage
		selectedRefreshInterval = settingsStorage?.refreshFrequency() ?? 0
	}
	var body: some View {
		VStack {
			VStack {
				HStack {
					Picker("Refresh", selection: $selectedRefreshInterval) {
						ForEach(refreshIntervals, id: \.1) { interval in
							Text(interval.0).tag(interval.1)
						}
					}
					.pickerStyle(MenuPickerStyle())
					.onChange(of: selectedRefreshInterval) {
						if Int(selectedRefreshInterval) > 0 {
							requestNotificationPermissions()
						}
						settingsStorage?.saveRefreshFrequency(Int(selectedRefreshInterval))
					}
				}
				Text("This uses network & battery, so make sure you know what you're doing if you set this more frequent than 1 hour.")
					.italic()
					.font(.system(size: 11))
					.foregroundColor(OceanViewApp.oceanBlue())

			}
			.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))

			Divider()

			VStack {
				HStack {
					Picker("Notification", selection: $notificationUrgency) {
						ForEach(urgencyMenu, id: \.1) { interval in
							Text(interval.0).tag(interval.1)
						}
					}
					.pickerStyle(MenuPickerStyle())
					.onChange(of: notificationUrgency) {
						let urgent: Bool = notificationUrgency > 0
						settingsStorage?.saveNotificationUrgency(urgent)
					}
				}
				HStack {
					if (notificationUrgency != 0) {
						Text("Plays a sound with the notiification")
							.italic()
							.font(.system(size: 11))
							.foregroundColor(OceanViewApp.oceanBlue())
							.lineLimit(1)
					} else {
						Text("Silently adds a badge")
							.italic()
							.font(.system(size: 11))
							.foregroundColor(OceanViewApp.oceanBlue())
							.lineLimit(1)
					}
					Spacer()
				}

			}
			.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))

			Divider()


			VStack() {
				if copyingToClipboard {
					VStack {
						HStack {
							Spacer()
							Text("Copied To Clipboard")
								.bold()
								.foregroundColor(.gray)
								.font(.system(size: 12))
							Spacer()
						}
						Text("Thank you for your consideration")
							.italic()
							.font(.system(size: 10))
							.foregroundColor(.gray)
					}
				} else {
					Button(action: copyToClipboard) {
						HStack {
							Text("Value 4 Value")
							Spacer()
							Text("btc99k at strike dot me")
								.foregroundColor(OceanViewApp.oceanBlue())
						}
					}
				}
			}
			.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
			.frame(height: 35)

		}
		.onAppear {
			selectedRefreshInterval = settingsStorage?.refreshFrequency() ?? 0
			if settingsStorage?.notificationUrgency() ?? false {
				notificationUrgency = 1
			} else {
				notificationUrgency = 0
			}
		}
	}

	private func copyToClipboard() {
		UIPasteboard.general.string = "btc99k@strike.me"
		withAnimation {
			copyingToClipboard = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			withAnimation {
				copyingToClipboard = false
			}
		}
	}

	private func requestNotificationPermissions() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			if granted {
				NSLog("Permission Granted")
			} else {
				NSLog("Permission Denied")
			}
		}
	}
}

#Preview {
	ContentSettingsView(settingsStorage: nil)
}
