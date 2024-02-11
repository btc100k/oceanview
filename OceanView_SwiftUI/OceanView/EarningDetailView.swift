//
//  EarningDetailView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI

struct EarningDetailView: View {
	@State var rotationDegree: Double = 0
	var item: OceanEarning
	var body: some View {

		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Image("blue_ocean_logo")
					.scaledToFit()
					.frame(width: 50, height: 50)
					.rotationEffect(Angle(degrees: rotationDegree))
					.onAppear {
						withAnimation(Animation.linear(duration: 60).repeatForever(autoreverses: false)) {
							rotationDegree = 360
						}
					}
				Text("Ocean.xyz").bold().foregroundColor(OceanViewApp.oceanBlue())
			}

			HStack {
				Text("Block Height").bold()
				Spacer()
				Text("\(item.height)").foregroundColor(OceanViewApp.oceanBlue())
			}

			HStack {
				Text("Date").bold()
				Spacer()
				Text(item.timestamp.dateString()).foregroundColor(OceanViewApp.oceanBlue())
			}

			HStack {
				Text("BTC Earned").bold()
				Spacer()
				Text(item.btcEarned.asBTC()).foregroundColor(OceanViewApp.oceanBlue())
			}

			HStack {
				Text("USD Earned").bold()
				Spacer()
				Text((item.btcEarned * item.btcusd).usdString()).foregroundColor(OceanViewApp.oceanBlue())
			}

			Link(destination: URL(string: "https://mempool.space/block/\(item.blockHash)") ?? URL(string:"https://mempool.space/")!) {
				HStack {
					Spacer()
					Text("See in mempool.space").bold().foregroundColor(OceanViewApp.oceanBlue())
					Spacer()
				}
			}
		}
		.padding()
	}}

#Preview {
	EarningDetailView(item: OceanEarning(earning: BlockEarning(hash: "000000000000000000009ef7ac2c30976bc7e05c2cdab10e5a5de7efd96492a7", earned: 0.01, fee: 0.00)))
}
