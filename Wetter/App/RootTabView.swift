//
//  RootTabView.swift
//  Wetter
//
//  App root: Wetter / Karten tabs. Orte and Einstellungen live in the Now
//  screen's top toolbar and open as navigation sheets — Orte is also the
//  quick-switch menu on long press. Orte is not the system search role: the
//  separated search pill is a button affordance (instant keyboard + round
//  trip), wrong for a dwell space like the locations list; its search field
//  lives inside the list instead.
//  Also owns the app-wide refresh triggers and the sheet
//  presentation shared by all tabs.
//

import SwiftUI
import WidgetKit

struct RootTabView: View {
	private let settingsService = SettingService.shared
	@Environment(Weather.self) private var weather: Weather
	@Environment(Location.self) private var location: Location
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@State private var presentation = NowPresentationCoordinator()
	@State private var modelFallbackToast: String?

	var body: some View {
		@Bindable var presentation = presentation
		ZStack(alignment: .top) {
			TabView(selection: $presentation.selectedTab) {
				Tab("Wetter", systemImage: "cloud.sun", value: AppTab.forecast) {
					NavigationStack {
						NowView()
					}
				}
				Tab("Karten", systemImage: "globe.europe.africa", value: AppTab.maps) {
					WeatherMapDetailView(settingsService: settingsService)
				}
			}
			.tabBarMinimizeBehavior(horizontalSizeClass == .regular || presentation.selectedTab == .maps ? .never : .onScrollDown)
			.layerPickerInspector(isPresented: $presentation.isLayerPickerPresented, settingsService: settingsService) {
				presentation.selectLayer($0, $1)
			}

			if let message = modelFallbackToast, presentation.sheet == nil {
				ToastBanner(message: message)
					.padding(.top, 8)
					.transition(.move(edge: .top).combined(with: .opacity))
					.task {
						try? await Task.sleep(for: .seconds(5))
						guard !Task.isCancelled else { return }
						withAnimation(.easeInOut(duration: 0.3)) { modelFallbackToast = nil }
					}
			}
		}
		.sheet(item: $presentation.sheet, content: NowSheetView.init)
		.onOpenURL { url in
			guard url.scheme == "wetter", url.host == "radar" else { return }
			presentation.selectedTab = .maps
		}
		.environment(presentation)
		.focusedSceneValue(presentation)
		.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
			refreshWeatherData(isForeground: true)
		}
		.onReceive(NotificationCenter.default.publisher(for: .weatherRefreshNeeded, object: nil)) { _ in
			refreshWeatherData()
		}
		.onReceive(NotificationCenter.default.publisher(for: .forecastModelFallback)) { _ in
			withAnimation(.spring(duration: 0.4)) {
				modelFallbackToast = String(localized: "Außerhalb des Modells – Automatik aktiv.")
			}
		}
	}

	private func refreshWeatherData(isForeground: Bool = false) {
		withAnimation(.easeInOut(duration: 0.3)) { modelFallbackToast = nil }
		Task {
			await weather.refresh(location: location)
			await NotificationSettingsManager.shared.syncLocationUpdate()
			await WidgetBasemapRenderer.refreshIfNeeded()
			if isForeground {
				WidgetCenter.shared.reloadAllTimelines()
			}
		}
	}
}

struct WetterCommands: Commands {
	@FocusedValue(NowPresentationCoordinator.self) private var presentation

	var body: some Commands {
		CommandMenu("Wetter") {
			Group {
				Button("Wetter") { presentation?.selectedTab = .forecast }
					.keyboardShortcut("1")
				Button("Karten") { presentation?.selectedTab = .maps }
					.keyboardShortcut("2")
				Button("Orte") { presentation?.present(.places) }
					.keyboardShortcut("3")
				Divider()
				Button("Aktualisieren") {
					NotificationCenter.default.post(name: .weatherRefreshNeeded, object: nil)
				}
				.keyboardShortcut("r")
			}
			.disabled(presentation == nil)
		}
		CommandGroup(replacing: .appSettings) {
			Button("Einstellungen") { presentation?.present(.settings) }
				.keyboardShortcut(",")
				.disabled(presentation == nil)
		}
	}
}

#Preview {
	RootTabView()
		.environment(Weather())
		.environment(Location())
		.preferredColorScheme(.dark)
}
