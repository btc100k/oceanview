//
//  ContentView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI
import SwiftData

struct EarningsGroup: Hashable {
	let month: String
	var btcTotal: Double = 0
	var usdTotal: Double = 0
	var usdAverage: Double = 0
	var earnings: [OceanEarning]

	func hash(into hasher: inout Hasher) {
		hasher.combine(month)
	}

	static func ==(lhs: EarningsGroup, rhs: EarningsGroup) -> Bool {
		lhs.month == rhs.month
	}
}

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.openURL) var openURL
	@Query private var items: [OceanEarning]
	@State private var isRefreshing = false
	@State private var rotationDegree: Double = 0
	@State private var selectedTab: Int = 0
	let addressStorage: AddressStorage?
	let d: Dumping

	init(addressStorage storage: AddressStorage?) {
		addressStorage = storage
		d = Dumping(addressStorage?.oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa");
	}

	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone.current
		return formatter
	}()

	static let monthlyFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM"
		formatter.timeZone = TimeZone.current
		return formatter
	}()

	static let currencyFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = Locale.current
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		return formatter
	}()

	func usdString(_ usdTotal: Double) -> String {
		return ContentView.currencyFormatter.string(from: NSNumber(value: usdTotal)) ?? "$0.00"
	}

	func dateString(_ timestamp: Int) -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
		return ContentView.dateFormatter.string(from: date)
	}

	func monthlyDateString(_ timestamp: Int) -> String {
		let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
		return ContentView.monthlyFormatter.string(from: date)
	}

	var sortedItems: [OceanEarning] {
		// newest to oldest
		items.sorted { $0.timestamp > $1.timestamp }
	}

	var monthlyItems: [EarningsGroup] {
		var groups: [String: EarningsGroup] = [:]

		for item in items {
			let monthKey = monthlyDateString(item.timestamp)
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
		NavigationSplitView {
			if isRefreshing {
				HStack {
					Image("blue_ocean_logo")
						.scaledToFit()
						.frame(width: 50, height: 50)
						.rotationEffect(Angle(degrees: rotationDegree))
						 .onAppear {
							 withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
								 rotationDegree = 360
							 }
						 }
					Text("Loading...")
						.bold()
						.foregroundColor(OceanViewApp.oceanBlue())

				}
			} else {
				List {
					if selectedTab == 0 {
						// Display items
						ForEach(sortedItems, id: \.self) { item in
							NavigationLink(destination: EarningDetailView(item: item)) {
								VStack(alignment: .leading) {
									Text("\(item.btcEarned.asBTC()) BTC Earned")
										.font(.headline)
									Text("\(dateString(item.timestamp))")
										.font(.subheadline)
										.foregroundColor(.gray)
								}
							}
						}
					} else if selectedTab == 1 {
						// Display monthlyItems
						ForEach(monthlyItems, id: \.self) { monthlyItem in
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
										Text("\(usdString(monthlyItem.usdTotal))")
											.font(.footnote)
											.foregroundColor(.gray)
									}
									Spacer()
									VStack(alignment: .trailing) {
										Text("BTCUSD Average")
											.font(.footnote)
											.foregroundColor(.gray)
										Text("\(usdString(monthlyItem.usdAverage))")
											.font(.footnote)
											.foregroundColor(.gray)
									}
								}
							}
						}
					}
				}
				.navigationBarTitleDisplayMode(.inline)
				.listStyle(DefaultListStyle())
				.toolbar {
					ToolbarItem(placement: .principal) {
						Button(action: {
							openURL(URL(string: "https://ocean.xyz/stats/\(addressStorage?.oceanAddress() ?? "https://ocean.xyz")")!)
						}) {
							Text(addressStorage?.oceanAddress() ?? "")
								.font(.system(size: 13))
								.lineLimit(1)
								.truncationMode(.middle)
								.foregroundColor(OceanViewApp.oceanBlue())
						}
					}

					ToolbarItem(placement: .principal) {
						Text(addressStorage?.oceanAddress() ?? "")
							.font(.system(size: 13)) // Smaller font size
							.lineLimit(1)
							.truncationMode(.middle) // Truncate in the middle
							.foregroundColor(OceanViewApp.oceanBlue())
					}

					ToolbarItem(placement: .navigationBarLeading) {
						Button(action: {
							Task {
								isRefreshing = true
								await deleteAll()
								if let storage = addressStorage {
									storage.saveOceanAddress(nil)
								}
								isRefreshing = false
							}
						}) {
							Label("Logout", systemImage: "power")
						}
						.foregroundColor(OceanViewApp.oceanBlue())
					}
					ToolbarItem(placement: .navigationBarTrailing) {
						if isRefreshing {
							ProgressView()
						} else {
							Button(action: {
								Task {
									await performRefreshAction()
								}
							}) {
								Label("Refresh", systemImage: "arrow.clockwise")
							}
							.foregroundColor(OceanViewApp.oceanBlue())
						}
					}
				}
				Picker("Tabs", selection: $selectedTab) {
					Text("Earnings").tag(0)
					Text("Monthly").tag(1)
				}
				.pickerStyle(.segmented)
			}
		}
		detail: {
			Text("Select an item")
		}
		.onAppear {
			Task {
				if items.isEmpty {
					await performRefreshAction()
				}
			}
		}
		.tint(OceanViewApp.oceanBlue())
	}

	private func deleteAll() async {
		for removeMe in items {
			modelContext.delete(removeMe)
		}
		do {
			try modelContext.save()
		} catch {
			print("Error saving context after deletes: \(error)")
		}
	}

	private func performRefreshAction() async {
		isRefreshing = true
		await d.refresh()
		await deleteAll()
		let earnings = await d.allEarnings()
		for one in earnings {
			let newItem = OceanEarning(earning: one)
			modelContext.insert(newItem)
		}
		do {
			try modelContext.save()
		} catch {
			print("Error saving context after insert: \(error)")
		}
		isRefreshing = false
	}
}

#Preview {
	ContentView(addressStorage: nil)
		.modelContainer(for: OceanEarning.self, inMemory: false)
}
