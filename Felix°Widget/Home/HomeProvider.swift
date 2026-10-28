//
//  HomeProvider.swift
//  Felix°WidgetExtension
//
//  Created by Philipp Bolte on 03.06.23.
//

import CoreLocation
import Foundation
import SwiftUI
import WidgetKit

struct HomeEntry: TimelineEntry {
	let date: Date
	let location: String
	let temperatureMin: Double
	let temperatureMax: Double
	let temperatureNow: Double
	let icon: String
}

final class HomeProvider: TimelineProvider, Sendable {
	let client = APIClient.shared

	func placeholder(in context: Context) -> HomeEntry {
		HomeEntry(date: Date(), location: "Berlin", temperatureMin: 0, temperatureMax: 22, temperatureNow: 10, icon: "cloud.fill")
	}

	func getSnapshot(in context: Context, completion: @escaping @Sendable (HomeEntry) -> Void) {
		let entry = HomeEntry(date: Date(), location: "Berlin", temperatureMin: 0, temperatureMax: 22, temperatureNow: 10, icon: "cloud.fill")
		completion(entry)
	}

	func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<HomeEntry>) -> Void) {
		runWidgetTimeline(refreshMinutes: 30, completion: completion) { coordinates in
			let locationName = await LocationService.shared.getLocationName()

			let weather = try await self.client.getForecast(
				coordinates: coordinates,
				forecastDays: ._1,
				hourly: [
					.weathercode, .cloudcover, .relativehumidity_2m,
					.precipitation, .snowfall, .windspeed_10m, .winddirection_10m,
				]
			)

			let temperatureMin = weather.daily?.temperature_2m_min?.first ?? 0
			let temperatureMax = weather.daily?.temperature_2m_max?.first ?? 0
			let temperatureNow = weather.current?.temperature ?? 0
			let weathercode = weather.current?.weathercode ?? 0
			let isDay = weather.current?.is_day ?? 0
			let precipitation = weather.current?.precipitation ?? 0

			return [
				HomeEntry(
					date: Date(),
					location: locationName,
					temperatureMin: temperatureMin,
					temperatureMax: temperatureMax,
					temperatureNow: temperatureNow,
					icon: WeatherSymbol.sfSymbol(weathercode: weathercode, isDay: isDay, isRaining: precipitation > 0, precipitation: precipitation)
				)
			]
		}
	}
}
