//
//  ContentView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI
import SwiftData

protocol SettingsDelegate {
	func reload() async
	func signout() async
	func copyAll() async
	func copy(items: [OceanEarning]) async
	var settingsStorage: SettingsStorage? { get }
}

struct ContentView: View, SettingsDelegate {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.openURL) var openURL
	@Environment(\.colorScheme) var colorScheme
	@Query private var items: [OceanEarning]
	@Binding var isRefreshing: Bool
	@State private var selectedTab: Int = 0
	let addressStorage: AddressStorage?
	let localStorage: LocalStorage?
	let settingsStorage: SettingsStorage?

	var sortedItems: [OceanEarning] {
		// newest to oldest
		items.sorted { $0.timestamp > $1.timestamp }
	}

	var body: some View {
		NavigationSplitView {
			List {
				if selectedTab == 0 {
					ContentEarningsView()
				} else if selectedTab == 1 {
					ContentMonthlyView(delegate: self)
				} else if selectedTab == 2 {
					ContentSettingsView(delegate: self)
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
							.foregroundColor(OceanViewApp.oceanBlue(for: colorScheme))
					}
				}
			}
			Picker("Tabs", selection: $selectedTab) {
				Text("Earnings").tag(0)
				Text("Monthly").tag(1)
				Text("Settings").tag(2)
			}
			.pickerStyle(.segmented)
		}
	detail: {
		Text("Select an item")
	}
	.onAppear {
		Task {
			if items.isEmpty {
				await reload()
			}
		}
	}
	.tint(OceanViewApp.oceanBlue(for: colorScheme))
	}

	func reload() async {
		let taskIdentifier = await UIApplication.shared.beginBackgroundTask();
		isRefreshing = true
		let d = Dumping(addressStorage?.oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa")
		await d.refresh()
		let earnings = await d.allEarnings()
		await localStorage?.replace(earnings: earnings)
		selectedTab = 0
		isRefreshing = false
		await UIApplication.shared.endBackgroundTask(taskIdentifier)
	}

	func signout() async {
		isRefreshing = true
		await localStorage?.deleteEarnings()
		if let storage = addressStorage {
			storage.saveOceanAddress(nil)
		}
		selectedTab = 0
		isRefreshing = false
	}

	func copyAll() async {
		await addToClipboard(sortedItems)
	}

	func copy(items: [OceanEarning]) async {
		await addToClipboard(items)
	}

	private func addToClipboard(_ copyItems: [OceanEarning]) async {
		var list: [String] = []
		list.append("Date\tBTC Amount\tUSD Amount\tBTCUSD\tBlock Height")
		for item in copyItems {
			list.append("\(item.timestamp.dateString())\t\(item.btcEarned.asBTC())\t\((item.btcEarned * item.btcusd).usdString())\t\(item.btcusd.usdString())\t\(item.height)")
		}
		var output = list.joined(separator: "\n")
		output = output.replacingOccurrences(of: ",", with: "")
		output = output.replacingOccurrences(of: "\t", with: ",")
		UIPasteboard.general.string = output
	}
}

struct ContentView_Previews: PreviewProvider {
	@State static var isRefreshing = true

	static var previews: some View {
		ContentView(isRefreshing: $isRefreshing, addressStorage: nil, localStorage: nil, settingsStorage: nil)
	}
}
