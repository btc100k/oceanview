//
//  ContentMonthlyView.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import SwiftUI
import SwiftData

struct ContentMonthlyView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var items: [OceanEarning]

	var monthlyItems: [EarningsGroup] {
		var groups: [String: EarningsGroup] = [:]

		for item in items {
			let monthKey = item.timestamp.monthlyDateString()
			if groups[monthKey] == nil {
				groups[monthKey] = EarningsGroup(month: monthKey, earnings: [])
			}
			groups[monthKey]?.btcTotal += item.btcEarned
			groups[monthKey]?.usdTotal += (item.btcEarned * item.btcusd)
			if let one = groups[monthKey] {
				groups[monthKey]?.usdAverage = (one.usdTotal / one.btcTotal)
			}
			groups[monthKey]?.earnings.append(item)
		}

		// sort newest to oldest
		return Array(groups.values).sorted { $0.month > $1.month }
	}
	var body: some View {
		ForEach(monthlyItems, id: \.self) { monthlyItem in
			NavigationLink(destination: MonthlyDetailView(items: monthlyItem.earnings)) {
				VStack(alignment: .leading) {
					HStack {
						Text("\(monthlyItem.month)")
							.font(.subheadline)
							.bold()
							.foregroundColor(.gray)
						Spacer()
						Text("\(monthlyItem.btcTotal.asBTC()) BTC Earned")
							.font(.headline)
					}
					HStack {
						VStack(alignment: .leading) {
							Text("USD Earned")
								.font(.footnote)
								.foregroundColor(.gray)
							Text("\(monthlyItem.usdTotal.usdString())")
								.font(.footnote)
								.foregroundColor(.gray)
						}
						Spacer()
						VStack(alignment: .trailing) {
							Text("BTCUSD Average")
								.font(.footnote)
								.foregroundColor(.gray)
							Text("\(monthlyItem.usdAverage.usdString())")
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
	ContentMonthlyView()
		.modelContainer(for: OceanEarning.self, inMemory: false)
}
