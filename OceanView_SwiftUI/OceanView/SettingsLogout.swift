//
//  SettingsLogout.swift
//  OceanView
//
//  Created by Raymond on 3/3/24.
//

import SwiftUI

struct SettingsLogout: View {
	let delegate: SettingsDelegate?
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack {
			HStack {
				Text("Logout")
				Spacer()
				Image(systemName: "power")
					.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
			}
			HStack{
				Text("Delete local data & log out")
					.italic()
					.font(.system(size: 11))
					.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
					.lineLimit(1)
				Spacer()

			}
		}
		.onTapGesture {
			Task {
				await delegate?.signout()
			}
		}
	}
}

#Preview {
	SettingsLogout(delegate: nil)
}
