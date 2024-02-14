//
//  AddressView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI

struct AddressView: View {
	@State private var btcAddress = OceanViewApp.oceanAddress() ?? ""
	@Environment(\.colorScheme) var colorScheme
	var addressStorage: AddressStorage?

	var body: some View {
		NavigationView {
			VStack {
				HStack {
					Image("blue_ocean_logo")
						.resizable()
						.scaledToFit()
						.frame(width: 50, height: 50)
					Text("Ocean Pool").bold().foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
					Spacer()
				}.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))

				TextField("Enter BTC Address", text: $btcAddress)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()

				Button("My Stats") {
					if let storage = addressStorage {
						storage.saveOceanAddress(btcAddress)
					}
				}
				.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
				.padding()
			}
		}
	}
}

#Preview {
	AddressView(addressStorage: nil)
}
