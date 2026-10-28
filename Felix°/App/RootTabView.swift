//
//  RootTabView.swift
//  Felix°
//
//  App root: the Wetter screen. Orte and Einstellungen live in the Now
//  screen's top toolbar and open as navigation sheets — Orte is also the
//  quick-switch menu on long press.
//  Also owns the app-wide refresh triggers and the sheet presentation.
//

import SwiftUI
import WidgetKit

struct RootTabView: View {
	@Environment(Weather.self) private var weather: Weather
	@Environment(Location.self) private var location: Location
	@State private var presentation = NowPresentationCoordinator()
	@State private var modelFallbackToast: String?

	var body: some View {
		@Bindable var presentation = presentation
		ZStack(alignment: .top) {
			NavigationStack {
				NowView()
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
			if isForeground {
				WidgetCenter.shared.reloadAllTimelines()
			}
		}
	}
}

struct FelixCommands: Commands {
	@FocusedValue(NowPresentationCoordinator.self) private var presentation

	var body: some Commands {
		CommandMenu("Wetter") {
			Group {
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
