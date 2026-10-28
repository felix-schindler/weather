//
//  WatchRootView.swift
//  Felix°Watch Watch App
//

import SwiftUI

struct WatchRootView: View {
	@State private var selection = min(2, max(0, UserDefaults.standard.integer(forKey: "watchPage")))

	var body: some View {
		TabView(selection: $selection) {
			WatchNowView()
				.tag(0)

			WatchHourlyView()
				.tag(1)

			WatchDailyView()
				.tag(2)
		}
		.tabViewStyle(.verticalPage)
		.preferredColorScheme(.dark)
	}
}

#Preview {
	WatchRootView()
		.environment(Weather.mock)
		.environment(Location())
}
