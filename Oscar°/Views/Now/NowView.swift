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
        return form.isWide
            ? arrangement.stageSections + arrangement.feedSections
            : arrangement.pageSections
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
        .environment(\.cardBackgroundStyle, AnyShapeStyle(.ultraThinMaterial.opacity(0.6)))
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
                        .padding(.vertical, 14)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }

            if sections.isEmpty {
                Button("Abschnitte hinzufügen", systemImage: "plus") {
                    Haptics.impact()
                    presentation.present(.layout)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            footer
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            if weather.debug {
                debugDump
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await weather.refresh(location: location)
        }
        .animation(.snappy, value: sections)
        .onGeometryChange(for: CGSize.self, of: { $0.size }) { size in
            form = LayoutForm.of(size)
            LayoutFrame.rememberWideWindow(size)
        }
    }

    private var footer: some View {
        VStack(spacing: 0) {
            HStack(spacing: 24) {
                ProviderLogo(asset: "logo-dwd", height: 36)
                ProviderLogo(asset: "logo-open-meteo", height: 32)
                ProviderLogo(asset: "logo-oscar-server", height: 28)
            }
            .foregroundStyle(.primary)
            .opacity(0.7)
            .adaptiveShadow(opacity: 0.35, radius: 1)
            .adaptiveShadow(opacity: 0.45, radius: 8, y: 2)
            .padding(12)
            .drawingGroup()
            .padding(-12)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: "DWD, Open-Meteo & Oscar Server"))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 16)
            .padding(.top, 28)
            Button {
                Haptics.impact()
                presentation.present(.settings)
            } label: {
                Label("Einstellungen", systemImage: "gearshape")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .opacity(0.7)
                    .adaptiveShadow(opacity: 0.35, radius: 1)
                    .adaptiveShadow(opacity: 0.45, radius: 8, y: 2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .contentShape(Rectangle())
            }
            .accessibilityIdentifier("now.settings")
            .frame(maxWidth: .infinity)
            .padding(.bottom, 24)
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
