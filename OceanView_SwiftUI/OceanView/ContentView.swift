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
	@Query private var items: [OceanEarning]
	@State private var isRefreshing = false
	let addressStorage: AddressStorage?
	let d: Dumping

	init(addressStorage storage: AddressStorage?) {
		addressStorage = storage
		d = Dumping(addressStorage?.oceanAddress() ?? "1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa");
	}

	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
		return formatter
	}()

	var sortedItems: [OceanEarning] {
		// newest to oldest
		items.sorted { $0.timestamp > $1.timestamp }
	}
	var body: some View {
		NavigationSplitView {
			List(sortedItems) { item in


				NavigationLink(destination: EarningDetailView(item: item)) {
					VStack(alignment: .leading) {
						Text("\(item.btcEarned.asBTC()) BTC Earned")
							.font(.headline)
							//.foregroundColor(OceanViewApp.oceanBlue())

						Text("\(ContentView.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(item.timestamp))))")
							.font(.subheadline)
							.foregroundColor(.gray)

					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			//.listStyle(PlainListStyle())
			.listStyle(DefaultListStyle())
			.toolbar {
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
