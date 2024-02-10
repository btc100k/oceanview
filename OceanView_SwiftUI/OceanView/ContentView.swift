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
	@State private var copyingToClipboard: Bool = false
	let addressStorage: AddressStorage?
	let localStorage: LocalStorage?
	let refreshStorage: RefreshStorage?
	let d: Dumping

	init(addressStorage storage: AddressStorage?, localStorage lstorage: LocalStorage?, refreshStorage rStorage: RefreshStorage?) {
		addressStorage = storage
		localStorage = lstorage
		refreshStorage = rStorage
		d = Dumping(addressStorage?.oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa");
		selectedRefreshInterval = refreshStorage?.refreshFrequency() ?? 0
	}

	var sortedItems: [OceanEarning] {
		// newest to oldest
		items.sorted { $0.timestamp > $1.timestamp }
	}

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

	let refreshIntervals = [("Manual Only", 0),
							("1 minute (Don't do this)", 60),
							("5 minutes", 300),
							("15 minutes", 900),
							("1 hour", 3600),
							("6 hours", 21600),
							("12 hours", 43200),
							("24 hours", 86400),
							("48 hours", 172800),
	]
	@State private var selectedRefreshInterval = 0

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
									Text("\(item.timestamp.dateString())")
										.font(.subheadline)
										.foregroundColor(.gray)
								}
							}
						}
					} else if selectedTab == 1 {
						// Display monthlyItems
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
					} else if selectedTab == 2 {
						VStack {
							HStack {
								Picker("Refresh", selection: $selectedRefreshInterval) {
									ForEach(refreshIntervals, id: \.1) { interval in
										Text(interval.0).tag(interval.1)
									}
								}
								.pickerStyle(MenuPickerStyle())
								.onChange(of: selectedRefreshInterval) {
									refreshStorage?.saveRefreshFrequency(Int(selectedRefreshInterval))
								}
							}
							Text("This uses network & battery, so make sure you know what you're doing if you set this more frequent than 1 hour.")
								.italic()
								.font(.system(size: 11))
								.foregroundColor(OceanViewApp.oceanBlue())

						}

						if copyingToClipboard {
							VStack {
								HStack {
									Spacer()
									Text("Copied To Clipboard")
										.bold()
										.foregroundColor(.gray)
										.font(.system(size: 12))
									Spacer()
								}
								Text("Thank you for your consideration")
									.italic()
									.font(.system(size: 10))
									.foregroundColor(.gray)
							}
						} else {
							Button(action: copyToClipboard) {
								HStack {
									Text("Value 4 Value")
									Spacer()
									Text("btc99k at strike dot me")
										.foregroundColor(OceanViewApp.oceanBlue())
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
								await localStorage?.deleteEarnings()
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
					Text("Settings").tag(2)
				}
				.pickerStyle(.segmented)
				.onChange(of: selectedTab, initial: false) {
					if selectedTab == 2 {
						selectedRefreshInterval = refreshStorage?.refreshFrequency() ?? 0
					}
				}
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

	func copyToClipboard() {
		UIPasteboard.general.string = "btc99k@strike.me"
		withAnimation {
			copyingToClipboard = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			withAnimation {
				copyingToClipboard = false
			}
		}
	}

	private func performRefreshAction() async {
		isRefreshing = true
		await d.refresh()
		let earnings = await d.allOceanEarnings()
		await localStorage?.replace(earnings: earnings)
		isRefreshing = false
	}
}

#Preview {
	ContentView(addressStorage: nil, localStorage: nil, refreshStorage: nil)
		.modelContainer(for: OceanEarning.self, inMemory: false)
}
