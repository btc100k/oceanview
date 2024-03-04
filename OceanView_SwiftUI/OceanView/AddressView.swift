//
//  AddressView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI

struct AddressView: View {
	@State private var btcAddress = OceanViewApp.oceanAddress() ?? ""
	@Binding var isRefreshing: Bool
	@Environment(\.colorScheme) var colorScheme
	var addressStorage: AddressStorage?
	var localStorage: LocalStorage?

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
					Task {
						isRefreshing = true
						if let storage = addressStorage {
							if let lstorage = localStorage {
								let d = Dumping(btcAddress)
								await d.refresh()
								let earnings = await d.allEarnings()
								await lstorage.replace(earnings: earnings)
							}
							storage.saveOceanAddress(btcAddress)
						}
						isRefreshing = false
					}
				}
				.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
				.padding()
			}
		}
	}
}

struct AddressView_Previews: PreviewProvider {
	@State static var isRefreshing = true
	
	static var previews: some View {
		AddressView(isRefreshing: $isRefreshing, addressStorage: nil, localStorage: nil)
	}
}
