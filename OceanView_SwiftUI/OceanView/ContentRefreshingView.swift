//
//  ContentRefreshingView.swift
//  OceanView
//
//  Created by Raymond on 2/10/24.
//

import SwiftUI

struct ContentRefreshingView: View {
	@State private var rotationDegree: Double = 0
    var body: some View {
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
    }
}

#Preview {
    ContentRefreshingView()
}
