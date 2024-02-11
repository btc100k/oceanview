//
//  ContentEarningsView.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import SwiftUI
import SwiftData

struct ContentEarningsView: View {
	@Environment(\.modelContext) private var modelContext
	@Query private var items: [OceanEarning]

	var sortedItems: [OceanEarning] {
		// newest to oldest
		items.sorted { $0.timestamp > $1.timestamp }
	}

	var body: some View {
		ForEach(sortedItems, id: \.self) { item in
			NavigationLink(destination: EarningDetailView(item: item)) {
				VStack(alignment: .leading) {
					Text("\(item.btcEarned.asBTC()) BTC Earned")
						.font(.headline)
					Text("\(item.timestamp.dateString())")
						.font(.subheadline)
						.foregroundColor(.gray)
				}
			}
		}
	}
}

#Preview {
	ContentEarningsView()
		.modelContainer(for: OceanEarning.self, inMemory: false)
}
