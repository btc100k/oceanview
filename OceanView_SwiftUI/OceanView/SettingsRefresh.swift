//
//  SettingsRefresh.swift
//  OceanView
//
//  Created by Raymond on 3/3/24.
//

import SwiftUI

struct SettingsRefresh: View {
	@State var selectedRefreshInterval: Int = 0
	@Environment(\.colorScheme) var colorScheme
	let delegate: SettingsDelegate?
	let refreshIntervals = [("Manual Only", 0),
							("5 minutes", 300),
							("15 minutes", 900),
							("1 hour", 3600),
							("6 hours", 21600),
							("12 hours", 43200),
							("24 hours", 86400),
							("48 hours", 172800),
	]

	var body: some View {
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
					delegate?.settingsStorage?.saveRefreshFrequency(Int(selectedRefreshInterval))
				}
			}
			Text("This uses network & battery, so make sure you know what you're doing if you set this more frequent than 1 hour.")
				.italic()
				.font(.system(size: 11))
				.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))

		}
		.onAppear {
			selectedRefreshInterval = delegate?.settingsStorage?.refreshFrequency() ?? 0
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
	SettingsRefresh(delegate: nil)
}
