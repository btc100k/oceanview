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
	MonthlyDetailView(items: [OceanEarning(earning: BlockEarning(hash: "000000000000000000021e98215d3064e83061e88a3d78f9dc2088364cab4984"
																 , earned: 0.01
																 , fee: 0.00
																 , ht: 829933
																 , ts: 1707673321
																 , usd: 48321.70)),
							  OceanEarning(earning: BlockEarning(hash: "00000000000000000001400a421f4fae3a8fb9bc73dfc9fa80dba6ec2035e25c"
																 , earned: 0.0125
																 , fee: 0.00
																 , ht: 829513
																 , ts: 1707366805
																 , usd: 44335.00))
							 ])
}
