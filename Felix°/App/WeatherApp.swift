//
//  WeatherApp.swift
//  Felix°
//
//  Created by Philipp Bolte on 22.09.20.
//

import CoreLocation
import SwiftUI
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
	nonisolated(unsafe) private var memoryWarningObserver: NSObjectProtocol?

	func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
	) -> Bool {
		memoryWarningObserver = NotificationCenter.default.addObserver(
			forName: UIApplication.didReceiveMemoryWarningNotification,
			object: nil,
			queue: .main
		) { _ in
			Task { @MainActor in
				await CacheStore.shared.dropMemory()
				await ClimateArchiveStore.shared.dropMemory()
				await APIClient.ensembleCache.dropMemory()
			}
		}
		return true
	}

	deinit {
		if let memoryWarningObserver {
			NotificationCenter.default.removeObserver(memoryWarningObserver)
		}
	}
}

@main
struct WeatherApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	init() {
		URLCache.shared = URLCache(
			memoryCapacity: 50 * 1024 * 1024,
			diskCapacity: 500 * 1024 * 1024
		)

		#if DEBUG
			if ScreenshotMode.bootstrap() {
				location.coordinates = CLLocationCoordinate2D(
					latitude: ScreenshotFixtures.latitude,
					longitude: ScreenshotFixtures.longitude
				)
				location.name = "Leipzig"
				return
			}
		#endif

		locationService.city.applyDefaultSelectionOnLaunch()
		hydrateFromCache()
	}

	@State private var weather = Weather()
	@State private var location = Location()
	private let locationService = LocationService.shared
	private let persistenceController = PersistenceController.shared

	var body: some Scene {
		WindowGroup {
			ZStack {
				#if DEBUG
					if ScreenshotMode.scene == .widgets {
						ScreenshotWidgetGallery()
					} else {
						RootTabView()
						OnboardingGate()
					}
				#else
					RootTabView()
					OnboardingGate()
				#endif
			}
			.environment(\.managedObjectContext, persistenceController.container.viewContext)
			.environment(weather)
			.environment(location)
			.task {
				hydrateFromCache()
				await weather.refresh(location: location)
			}
		}
		.commands { FelixCommands() }
	}

	private func hydrateFromCache() {
		guard !ScreenshotMode.active, weather.lastUpdated == nil else { return }
		guard let snapshot = WeatherSnapshotStore.load() else { return }
		locationService.update()
		if let current = locationService.knownCoordinates(),
			!WeatherSnapshotStore.coordinatesMatch(snapshot: snapshot.coordinates, current: current)
		{
			return
		}
		weather.apply(snapshot: snapshot, location: location)
	}
}
