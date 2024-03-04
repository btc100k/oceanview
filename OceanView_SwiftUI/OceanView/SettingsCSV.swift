//
//  SettingsCSV.swift
//  OceanView
//
//  Created by Raymond on 3/3/24.
//

import SwiftUI

struct SettingsCSV: View {
	let delegate: SettingsDelegate?
	@State var copied: Bool = false
	@Environment(\.colorScheme) var colorScheme

	var body: some View {
		VStack {
			HStack {
				if copied {
					Spacer()
					Text("Copied")
						.italic()
						.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
					Spacer()
				} else {
					Text("Copy CSV")
					Spacer()
					Image(systemName: "square.on.square")
						.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
				}
			}
			HStack{
				if copied {
					Text("")
						.italic()
						.font(.system(size: 11))
						.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
				} else {
					Text("Copy all earnings data as comma separated values")
						.italic()
						.font(.system(size: 11))
						.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
				}
				Spacer()
			}
		}
		.onTapGesture {
			Task {
				withAnimation {
					copied = true
				}
				await delegate?.copyAll()
				DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
					withAnimation {
						copied = false
					}
				}
			}
		}
	}
}

#Preview {
	SettingsCSV(delegate: nil)
}
