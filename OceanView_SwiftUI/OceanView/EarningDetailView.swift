//
//  EarningDetailView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI

struct EarningDetailView: View {
	var item: OceanEarning
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
		return formatter
	}()

	private func currencyFormattedString(from number: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = Locale(identifier: "en_US")
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2

		return formatter.string(from: NSNumber(value: number)) ?? "$0.00"
	}

	var body: some View {

		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Image("blue_ocean_logo")
					.scaledToFit()
					.frame(width: 50, height: 50)
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
				Text(EarningDetailView.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(item.timestamp)))).foregroundColor(OceanViewApp.oceanBlue())
			}

			HStack {
				Text("BTC Earned").bold()
				Spacer()
				Text(item.btcEarned.asBTC()).foregroundColor(OceanViewApp.oceanBlue())
			}

			HStack {
				Text("USD Earned").bold()
				Spacer()
				Text(currencyFormattedString(from: item.btcEarned * item.btcusd)).foregroundColor(OceanViewApp.oceanBlue())
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
