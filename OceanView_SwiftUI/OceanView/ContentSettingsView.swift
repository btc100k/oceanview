//
//  ContentSettingsView.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import SwiftUI

struct ContentSettingsView: View {
	@State private var notificationUrgency = 0
	@State private var showingDisclaimer = false
	@Environment(\.colorScheme) var colorScheme

	let delegate: SettingsDelegate?

	init(delegate sDelegate: SettingsDelegate?) {
		delegate = sDelegate
	}
	
	var body: some View {
		SettingsRefresh(delegate: delegate)
		SettingsNotification(delegate: delegate)
		SettingsCSV(delegate: delegate)
		SettingsReload(delegate: delegate)
		SettingsDisclaimer(showingDisclaimer: $showingDisclaimer)
		SettingsLogout(delegate: delegate)

		.sheet(isPresented: $showingDisclaimer) {
			DisclaimerView(showingDisclaimer: $showingDisclaimer)
		}
	}
}

#Preview {
	ContentSettingsView(delegate: nil)
}
