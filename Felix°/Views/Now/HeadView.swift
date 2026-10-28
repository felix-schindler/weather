//
//  HeadView.swift
//  Felix°
//
//  Created by Philipp Bolte on 24.10.20.

import CoreLocation
import SwiftUI

struct HeadView: View {
	var compact = false
	@Environment(Weather.self) private var weather: Weather
	@Environment(Location.self) private var location: Location
	@Environment(NowPresentationCoordinator.self) private var presentation
	@ScaledMetric(relativeTo: .largeTitle) private var temperatureFontSize: CGFloat = 72
	private let settingsService = SettingService.shared
	private let cityService = CityService.shared

	private static let temperatureGapMinHeight: CGFloat = 70
	private static let metricsGapMinHeight: CGFloat = 110

	private var metricsDescription: String {
		settingsService.headMetrics.compactMap { metric in
			metric.value(in: weather).map { "\(String(localized: metric.title)) \($0)" }
		}
		.joined(separator: ", ")
	}

	private var activePersonalization: PlacePersonalization {
		cityService.cities.first(where: { $0.selected })?.personalization
			?? cityService.currentLocationPersonalization
	}

	private var eyebrow: Text? {
		eyebrowDescription.map { Text(verbatim: $0) }
	}

	private var showsLocationGlyph: Bool {
		cityService.cities.first(where: { $0.selected }) == nil
			&& gpsAuthorized
			&& cityService.currentLocationPersonalization.mark == .locationGlyph
	}

	private var eyebrowDescription: String? {
		let personalization = activePersonalization
		let text = [personalization.mark.emoji, personalization.customLabel]
			.compactMap { $0 }
			.joined(separator: " ")
		return text.isEmpty ? nil : text
	}

	private var gpsAuthorized: Bool {
		let status = LocationService.shared.authStatus
		return status == .authorizedWhenInUse || status == .authorizedAlways
	}

	private var locationHeader: some View {
		VStack(spacing: 4) {
			if let eyebrow {
				eyebrow
					.font(.subheadline)
					.foregroundStyle(.secondary)
					.lineLimit(1)
			}
			HStack(spacing: 4) {
				if showsLocationGlyph {
					Image(systemName: "location.fill")
						.font(.subheadline.weight(.semibold))
						.foregroundStyle(.secondary)
				}
				Text(location.name)
					.font(.title2.bold())
					.lineLimit(1)
					.minimumScaleFactor(0.7)
					.multilineTextAlignment(.center)
			}
		}
	}

	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Spacer()
				locationHeader
				Spacer()
			}
			.contentShape(Rectangle())
			.onTapGesture {
				presentation.present(.places)
			}
			.contextMenu {
				LocationSwitchPicker()
				Divider()
				Button {
					presentation.present(.places)
				} label: {
					Label("Orte verwalten", systemImage: "list.bullet")
				}
			}
			.accessibilityElement(children: .combine)
			.accessibilityAddTraits(.isButton)
			.accessibilityLabel(
				Text("Ort ändern, aktuell \([eyebrowDescription, location.name].compactMap { $0 }.joined(separator: ", "))")
			)
			.accessibilityAction {
				presentation.present(.places)
			}
			.padding(.bottom, 10)

			VStack(spacing: 0) {
				Spacer(minLength: compact ? 8 : Self.temperatureGapMinHeight)

				Text(roundTemperatureString(temperature: weather.forecast.current?.temperature))
					.foregroundStyle(.primary)
					.font(.system(size: temperatureFontSize, weight: .medium, design: .rounded))
					.minimumScaleFactor(0.5)
					.lineLimit(1)
					.contentTransition(.numericText())
					.animation(.default, value: weather.forecast.current?.temperature)
					.accessibilityLabel(Text("Temperatur \(roundTemperatureString(temperature: weather.forecast.current?.temperature))"))

				Spacer(minLength: compact ? 16 : Self.metricsGapMinHeight)

				HStack(spacing: 18) {
					ForEach(settingsService.headMetrics) { metric in
						if let value = metric.value(in: weather) {
							HStack(spacing: 6) {
								Image(systemName: metric.systemImage)
								Text(value)
							}
						}
					}
				}
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, minHeight: 20)
				.contentShape(.rect)
				.onLongPressGesture {
					Haptics.impact()
					presentation.present(.layout)
				}
				.accessibilityElement(children: .ignore)
				.accessibilityIdentifier("now.metrics")
				.accessibilityLabel(Text(metricsDescription))
				.accessibilityActions {
					Button("Kennzahlen anpassen") { presentation.present(.layout) }
				}
			}
		}
	}

}
