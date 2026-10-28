//
//  LocationPreviewSheet.swift
//  Felix°
//
//  Forecast preview for a place that is not saved yet: the real simulation
//  and the Now screen's hourly/daily sections over a private Weather
//  instance, with cancel/add actions. Detail navigation stays inert — the
//  sheet answers "how is it there", the Now screen owns the deep dives.
//

import CoreLocation
import SwiftUI

struct LocationPreviewSheet: View {
	let candidate: LocationCandidate
	let onAdd: () -> Void

	@Environment(\.dismiss) private var dismiss
	@State private var weather = Weather()
	@State private var previewLocation: Location
	@State private var presentation = NowPresentationCoordinator()
	@State private var loadFailed = false
	@ScaledMetric(relativeTo: .largeTitle) private var temperatureFontSize: CGFloat = 96
	private let client = APIClient.shared

	init(candidate: LocationCandidate, onAdd: @escaping () -> Void) {
		self.candidate = candidate
		self.onAdd = onAdd
		let location = Location()
		location.coordinates = candidate.coordinate
		location.name = candidate.name
		_previewLocation = State(initialValue: location)
	}

	var body: some View {
		Group {
			if weather.hasContent {
				List {
					Section {
						header
					}

					Section("Stündlich") {
						HourlyView()
					}

					Section("Täglich") {
						DailyView()
					}
				}
				.listStyle(.insetGrouped)
				.transition(.opacity)
			} else if loadFailed {
				ContentUnavailableView {
					Label("Vorhersage nicht verfügbar", systemImage: "cloud.slash")
				} description: {
					Text("Die Wetterdaten konnten nicht geladen werden. Prüfe deine Verbindung und versuche es erneut.")
				} actions: {
					Button("Erneut versuchen") {
						loadFailed = false
						Task { await load() }
					}
					.buttonStyle(.borderedProminent)
				}
			} else {
				ProgressView()
					.controlSize(.large)
			}
		}
		.animation(.easeInOut(duration: 0.35), value: weather.hasContent)
		.safeAreaInset(edge: .bottom) {
			actionBar
		}
		.presentationDragIndicator(.visible)
		.environment(weather)
		.environment(previewLocation)
		.environment(presentation)
		.task {
			await load()
		}
	}

	private var header: some View {
		VStack(spacing: 4) {
			Text(candidate.name)
				.font(.title2.bold())
				.foregroundStyle(.primary)
				.lineLimit(2)
				.multilineTextAlignment(.center)
			Text(roundTemperatureString(temperature: weather.forecast.current?.temperature))
				.font(.system(size: temperatureFontSize, weight: .thin))
				.minimumScaleFactor(0.5)
				.lineLimit(1)
				.foregroundStyle(.primary)
				.contentTransition(.numericText())
		}
		.frame(maxWidth: .infinity)
		.accessibilityElement(children: .combine)
	}

	private var actionBar: some View {
		HStack(spacing: 12) {
			Button {
				dismiss()
			} label: {
				Text("Abbrechen")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.bordered)
			.controlSize(.large)

			Button {
				onAdd()
			} label: {
				Label("Hinzufügen", systemImage: "plus")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
		}
		.padding()
		.background(.bar)
	}

	private func load() async {
		do {
			let forecast = try await client.getForecast(coordinates: candidate.coordinate)
			weather.forecast = forecast
			weather.updateTime()
			weather.lastUpdated = .now
			weather.loadState = .loaded
		} catch {
			guard !Task.isCancelled else { return }
			loadFailed = true
		}
	}
}

#Preview {
	LocationPreviewSheet(
		candidate: LocationCandidate(
			name: "Leipzig",
			detail: "Sachsen, Deutschland",
			latitude: 51.34,
			longitude: 12.38
		)
	) {}
}
