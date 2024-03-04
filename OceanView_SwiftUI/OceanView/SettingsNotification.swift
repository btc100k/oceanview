//
//  SettingsNotification.swift
//  OceanView
//
//  Created by Raymond on 3/3/24.
//

import SwiftUI

struct SettingsNotification: View {
	@State private var notificationUrgency = 0
	@Environment(\.colorScheme) var colorScheme
	let delegate: SettingsDelegate?
	let urgencyMenu = [("Low Priority", 0),
					   ("High Priority", 1),
	]

	var body: some View {
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
					delegate?.settingsStorage?.saveNotificationUrgency(urgent)
				}
			}
			HStack {
				if (notificationUrgency != 0) {
					Text("Plays a sound with the notiification")
						.italic()
						.font(.system(size: 11))
						.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
						.lineLimit(1)
				} else {
					Text("Silently adds a badge")
						.italic()
						.font(.system(size: 11))
						.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
						.lineLimit(1)
				}
				Spacer()
			}
		}
		.onAppear {
			if delegate?.settingsStorage?.notificationUrgency() ?? false {
				notificationUrgency = 1
			} else {
				notificationUrgency = 0
			}
		}
    }
}

#Preview {
	SettingsNotification(delegate: nil)
}
