//
//  ScreenshotMode.swift
//  Felix°
//
//  App Store screenshot staging. Staged runs launch the
//  app with `-screenshotScene <rawValue>`; the bootstrap swaps the network
//  layer for ScreenshotFixtureServer so every prod code path runs unmodified
//  against deterministic data. Navigation happens through the real UI (the
//  tests tap), not through injected presentation state.
//

import CoreLocation
import Foundation
import SwiftUI

enum ScreenshotScene: String {
	case nowRain
	case nowClear
	case nowForecast
	case ensemble
	case airQuality
	case climate
	case customization
	case widgets
	case hourlyDetail
	case places
	case settingsForecast
	case onboarding
}

enum ScreenshotMode {
	static let scene: ScreenshotScene? = {
		#if DEBUG
			return UserDefaults.standard.string(forKey: "screenshotScene").flatMap(ScreenshotScene.init)
		#else
			return nil
		#endif
	}()

	static var active: Bool { scene != nil }

	#if !os(watchOS)
		static var onboardingStep: OnboardingStep? {
			#if DEBUG
				guard active else { return nil }
				return UserDefaults.standard.string(forKey: "onboardingStep").flatMap(OnboardingStep.init)
			#else
				return nil
			#endif
		}
	#endif

	@MainActor
	static func bootstrap() -> Bool {
		#if DEBUG
			guard let scene else { return false }
			URLProtocol.registerClass(ScreenshotFixtureServer.self)
			APIClient.stagingMiddlewares = [ScreenshotFixtureMiddleware()]
			APIClient.stagedFetch = { ScreenshotFixtureServer.stagedFetch($0) }
			#if !os(watchOS)
				seedPlaces(for: scene)
				seedSettings(for: scene)
			#else
				LocationService.shared.gpsLocation = CLLocationCoordinate2D(
					latitude: ScreenshotFixtures.latitude,
					longitude: ScreenshotFixtures.longitude
				)
			#endif
			return true
		#else
			return false
		#endif
	}

	#if DEBUG && !os(watchOS)
		@MainActor
		private static func seedPlaces(for scene: ScreenshotScene) {
			let cityService = CityService.shared
			LocationService.shared.gpsLocation = ScreenshotFixtures.gpsCoordinate
			if scene == .places {
				LocationService.shared.authStatus = .authorizedWhenInUse
			}
			if !cityService.cities.isEmpty {
				cityService.deleteCity(offsets: IndexSet(integersIn: cityService.cities.indices))
			}
			for place in ScreenshotFixtures.savedPlaces(for: scene) {
				cityService.addCity(name: place.name, latitude: place.latitude, longitude: place.longitude)
			}
			if scene == .places { cityService.disableAllCities() }
		}

		@MainActor
		private static func seedSettings(for scene: ScreenshotScene) {
			let settings = SettingService.shared
			settings.forecastModelPreference = scene == .settingsForecast ? .dwdICON : .bestMatch
			settings.dailyForecastDaytimeTemperaturesEnabled = scene == .settingsForecast
		}

		@MainActor
		static func stageOnAppear() async {}
	#endif
}

extension ScreenshotScene {
	var isSettings: Bool {
		self == .settingsForecast
	}
}
