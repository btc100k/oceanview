//
//  SettingsReload.swift
//  OceanView
//
//  Created by Raymond on 3/3/24.
//

import SwiftUI

struct SettingsReload: View {
	let delegate: SettingsDelegate?
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack {
			HStack {
				Text("Reload")
				Spacer()
				Image(systemName: "arrow.clockwise")
					.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
			}
			HStack{
				Text("Delete local data & download again")
					.italic()
					.font(.system(size: 11))
					.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
					.lineLimit(1)
				Spacer()

			}
		}
		.onTapGesture {
			Task {
				await delegate?.reload()
			}
		}
	}
}

#Preview {
	SettingsReload(delegate: nil)
}
