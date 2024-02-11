//
//  ContentView.swift
//  OceanView
//
//  Created by Raymond on 2/9/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.openURL) var openURL
	@Query private var items: [OceanEarning]
	@State private var isRefreshing = false
	@State private var selectedTab: Int = 0
	let addressStorage: AddressStorage?
	let localStorage: LocalStorage?
	let settingsStorage: SettingsStorage?

	init(addressStorage storage: AddressStorage?, localStorage lstorage: LocalStorage?, settingsStorage sStorage: SettingsStorage?) {
		addressStorage = storage
		localStorage = lstorage
		settingsStorage = sStorage
	}

	var sortedItems: [OceanEarning] {
		// newest to oldest
		items.sorted { $0.timestamp > $1.timestamp }
	}

	var body: some View {
		NavigationSplitView {
			if isRefreshing {
				ContentRefreshingView()
			} else {
				List {
					if selectedTab == 0 {
						ContentEarningsView()
					} else if selectedTab == 1 {
						ContentMonthlyView()
					} else if selectedTab == 2 {
						ContentSettingsView(settingsStorage: settingsStorage)
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
							.font(.system(size: 13))
							.lineLimit(1)
							.truncationMode(.middle)
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

	private func performRefreshAction() async {
		isRefreshing = true
		let d = Dumping(addressStorage?.oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa")
		await d.refresh()
		let earnings = await d.allEarnings()
		await localStorage?.replace(earnings: earnings)
		isRefreshing = false
	}
}

#Preview {
	ContentView(addressStorage: nil, localStorage: nil, settingsStorage: nil)
		.modelContainer(for: OceanEarning.self, inMemory: false)
}
