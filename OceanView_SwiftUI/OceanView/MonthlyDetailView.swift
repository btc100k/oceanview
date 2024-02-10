//
//  MonthlyDetailView.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import SwiftUI

struct MonthlyDetailView: View {
	var items: [OceanEarning]
	var sortedItems: [OceanEarning] {
		// newest to oldest
		items.sorted { $0.timestamp > $1.timestamp }
	}
	var body: some View {
		List {
			ForEach(sortedItems, id: \.self) { item in
				VStack(alignment: .leading) {
					HStack {
						Text("\(item.timestamp.dateString())")
							.font(.subheadline)
							.foregroundColor(.gray)
							.bold()
						Spacer()
						Text("\(item.btcEarned.asBTC()) BTC Earned")
							.font(.headline)
					}
					HStack {
						VStack(alignment: .leading) {
							Text("USD Value")
								.font(.footnote)
								.foregroundColor(.gray)
							Text("\((item.btcusd * item.btcEarned).usdString())")
								.font(.footnote)
								.foregroundColor(.gray)
						}
						Spacer()
						VStack(alignment: .trailing) {
							Text("BTCUSD")
								.font(.footnote)
								.foregroundColor(.gray)
							Text("\(item.btcusd.usdString())")
								.font(.footnote)
								.foregroundColor(.gray)
						}
					}
				}
			}
		}
	}
}

#Preview {
	MonthlyDetailView(items: [OceanEarning(earning: BlockEarning(hash: "000000000000000000009ef7ac2c30976bc7e05c2cdab10e5a5de7efd96492a7", earned: 0.01, fee: 0.00))])
}
