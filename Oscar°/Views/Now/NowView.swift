//
//  NowView.swift
//  Oscar°
//
//  Created by Philipp Bolte on 22.09.20.

import SwiftUI

#Preview {
    NowView()
        .environment(Weather())
        .environment(Location())
        .environment(NowPresentationCoordinator())
        .preferredColorScheme(.dark)
}

struct NowView: View {
    private let settingsService = SettingService.shared
    @Environment(Weather.self) private var weather: Weather
    @Environment(Location.self) private var location: Location
    @Environment(NowPresentationCoordinator.self) private var presentation
    @State private var tapCount = 0
    @State private var form: LayoutForm = .compact

    private var sections: [NowSection] {
        let arrangement = settingsService.arrangement(for: form)
        let visible = form.isWide
            ? arrangement.stageSections + arrangement.feedSections
            : arrangement.pageSections
        return visible.filter { $0.hasContent(in: weather) }
    }

    var body: some View {
        Group {
            if weather.hasContent {
                list
            } else if weather.loadState == .failed {
                WeatherUnavailableView(isRetrying: weather.isLoading) {
                    Task { await weather.refresh(location: location) }
                }
            }
        }
    }

    private var list: some View {
        List {
            HeadView(compact: true)
                .debugConsoleTap(countDebugTap)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            ForEach(sections) { section in
                Section {
                    section.view(openRadarMap: openRadarMap)
                } header: {
                    Text(section.title)
                }
            }

            if sections.isEmpty {
                Section {
                    Button("Abschnitte hinzufügen", systemImage: "plus") {
                        Haptics.impact()
                        presentation.present(.layout)
                    }
                }
            }

            if weather.debug {
                Section("Debug") {
                    debugDump
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await weather.refresh(location: location)
        }
        .animation(.snappy, value: sections)
        .onGeometryChange(for: CGSize.self, of: { $0.size }) { size in
            form = LayoutForm.of(size)
            LayoutFrame.rememberWideWindow(size)
        }
    }

    private var debugDump: some View {
        VStack {
            DebugPermissionControls()
            Text(weather.isLoading.description)
            Text(weather.error)
            Text("Air")
                .padding(.top, 20)
            Text(String(reflecting: weather.air))
            Text("Radar")
                .padding(.top, 20)
            Text(String(reflecting: weather.precipSeries))
            Text("Alerts")
                .padding(.top, 20)
            Text(String(reflecting: weather.alerts))
            Text("Time")
                .padding(.top, 20)
            Text(String(reflecting: weather.time))
            Text("Location")
                .padding(.top, 20)
            Text(String(reflecting: location.coordinates))
            Text(String(reflecting: location.name))
            Text("Forecast")
                .padding(.top, 20)
            Text(String(reflecting: weather.forecast))
        }
    }
}

private struct WeatherUnavailableView: View {
    let isRetrying: Bool
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Wetter nicht verfügbar", systemImage: "cloud.slash")
        } description: {
            Text("Die Wetterdaten konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.")
        } actions: {
            Button(action: retry) {
                if isRetrying {
                    ProgressView()
                } else {
                    Text("Erneut versuchen")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRetrying)
        }
    }
}

extension NowView {
    private func countDebugTap() {
        tapCount += 1
        guard tapCount == 10 else { return }
        tapCount = 0
        weather.debug.toggle()
        Haptics.impact()
    }

    private func openRadarMap() {
        settingsService.activeTileLayer = nil
        settingsService.oscarRadarLayer = true
        Haptics.impact()
        presentation.selectedTab = .maps
    }
}

private extension View {
    func debugConsoleTap(_ action: @escaping () -> Void) -> some View {
        simultaneousGesture(TapGesture().onEnded(action))
    }
}
