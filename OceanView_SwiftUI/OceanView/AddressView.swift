//
//  AddressView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI

struct AddressView: View {
	@State private var btcAddress = OceanViewApp.oceanAddress() ?? ""
	var addressStorage: AddressStorage?

	var body: some View {
		NavigationView {
			VStack {
				HStack {
					Image("blue_ocean_logo")
						.scaledToFit()
						.frame(width: 50, height: 50)
					Text("Ocean.xyz").bold().foregroundColor(OceanViewApp.oceanBlue())
					Spacer()
				}.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))

				TextField("Enter Ocean.xyz Address", text: $btcAddress)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()

				Button("My Stats") {
					if let storage = addressStorage {
						storage.saveOceanAddress(btcAddress)
					}
				}
				.foregroundColor(Color(red: 34/255, green: 58/255, blue: 245/255))
				.padding() // Add padding around the button
			}
		}
	}
}

#Preview {
	AddressView(addressStorage: nil)
}
