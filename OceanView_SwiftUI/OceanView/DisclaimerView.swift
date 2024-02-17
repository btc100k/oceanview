//
//  DisclaimerView.swift
//  OceanView
//
//  Created by Raymond on 2/16/24.
//

import SwiftUI

struct DisclaimerView: View {
	@Binding var showingDisclaimer: Bool
	@State private var copyingStrikeToClipboard: Bool = false
	@State private var copyingGithubToClipboard: Bool = false

	var body: some View {
		VStack {
			Spacer()
			Text("This Ocean Pool View app is independently developed and operated and is not sponsored or supported by OCEAN or its affiliate companies. \n\nThis is something a customer of OCEAN wanted to share with the community. OCEAN is operated by Bitcoin Ocean, LLC, a subsidiary of Mummolin, Inc., a Wyoming corporation.")
				.padding()
				.onTapGesture {
					showingDisclaimer = false
				}
			Divider()

			VStack() {
				if copyingStrikeToClipboard {
					VStack {
						HStack {
							Spacer()
							Text("Copied To Clipboard")
								.bold()
								.font(.system(size: 12))
							Spacer()
						}
						Text("Thank you for your consideration")
							.italic()
							.font(.system(size: 10))
					}
				} else {
					Button(action: strikeToClipboard) {
						HStack {
							Text("Value 4 Value")
								.frame(width: UIScreen.main.bounds.width / 3, alignment: .trailing)
							Spacer()
							Text("btc99k at strike dot me")
								.frame(width: UIScreen.main.bounds.width / 2, alignment: .leading)
						}
					}
				}
			}
			.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
			.frame(height: 50)
			Divider()

			VStack() {
				if copyingGithubToClipboard {
					VStack {
						HStack {
							Spacer()
							Text("Copied To Clipboard")
								.bold()
								.font(.system(size: 12))
							Spacer()
						}
						Text("Feel free to contribute")
							.italic()
							.font(.system(size: 10))
					}
				} else {
					Button(action: githubToClipboard) {
						HStack {
							Text("Github")
								.frame(width: UIScreen.main.bounds.width / 3, alignment: .trailing)
							Spacer()
							Text("btc100k/oceanview")
								.frame(width: UIScreen.main.bounds.width / 2, alignment: .leading)
						}
					}
				}
			}
			.padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
			.frame(height: 50)
			Divider()

			Button("Dismiss") {
				showingDisclaimer = false
			}
			.padding()
			Spacer()
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(.gray)
	}

	private func strikeToClipboard() {
		copyToClipboard("btc99k@strike.me", stateBool: $copyingStrikeToClipboard)
	}

	private func githubToClipboard() {
		copyToClipboard("https://github.com/btc100k/oceanview", stateBool: $copyingGithubToClipboard)
	}

	private func copyToClipboard(_ value: String, stateBool: Binding<Bool>) {
		UIPasteboard.general.string = value
		withAnimation {
			stateBool.wrappedValue = true
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			withAnimation {
				stateBool.wrappedValue = false
			}
		}
	}
}

struct DisclaimerView_Previews: PreviewProvider {
	// Create a static state for preview purposes
	@State static var showingDisclaimer = true

	static var previews: some View {
		// Pass the binding to the preview
		DisclaimerView(showingDisclaimer: $showingDisclaimer)
	}
}
