//
//  WatchRootView.swift
//  WetterWatch Watch App
//

import SwiftUI

struct WatchRootView: View {
    @Environment(Weather.self) private var weather: Weather

    @State private var selection = min(3, max(0, UserDefaults.standard.integer(forKey: "watchPage")))

    var body: some View {
        TabView(selection: $selection) {
            WatchNowView()
                .tag(0)

            if weather.precipSeries != nil {
                WatchRainView()
                    .tag(1)
            }

            WatchHourlyView()
                .tag(2)

            WatchDailyView()
                .tag(3)
        }
        .tabViewStyle(.verticalPage)
        .onChange(of: weather.precipSeries == nil) { _, isNil in
            if isNil, selection == 1 { selection = 0 }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    WatchRootView()
        .environment(Weather.mock)
        .environment(Location())
}
