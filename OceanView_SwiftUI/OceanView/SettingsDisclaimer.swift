//
//  SettingsDisclaimer.swift
//  OceanView
//
//  Created by Raymond on 3/3/24.
//

import SwiftUI

struct SettingsDisclaimer: View {
	@Binding var showingDisclaimer: Bool
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack {
			HStack {
				Text("Disclaimer")
				Spacer()
				Image(systemName: "info.circle")
					.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
			}
			HStack{
				Text("For more information")
					.italic()
					.font(.system(size: 11))
					.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
					.lineLimit(1)
				Spacer()

			}
		}
		.onTapGesture {
			showingDisclaimer = true
		}
    }
}

struct SettingsDisclaimer_Previews: PreviewProvider {
	@State static var showingDisclaimer = true

	static var previews: some View {
		SettingsDisclaimer(showingDisclaimer: $showingDisclaimer)
	}
}
