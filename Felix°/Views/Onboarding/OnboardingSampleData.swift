//
//  OnboardingSampleData.swift
//  Felix°
//

import Foundation

@MainActor
enum OnboardingSampleData {
	static let hourlyItems: [HourlyForecastItem] = [
		HourlyForecastItem(
			timestamp: 0,
			hour: String(localized: "Jetzt"),
			precipitation: "0 mm",
			iconName: "01d",
			temperature: "23°",
			isNow: true
		),
		HourlyForecastItem(
			timestamp: 1,
			hour: String(localized: "15 Uhr"),
			precipitation: "0 mm",
			iconName: "02d",
			temperature: "24°"
		),
		HourlyForecastItem(
			timestamp: 2,
			hour: String(localized: "16 Uhr"),
			precipitation: "0,2 mm",
			iconName: "10d",
			temperature: "22°",
			precipitationValue: 0.2
		),
		HourlyForecastItem(
			timestamp: 3,
			hour: String(localized: "17 Uhr"),
			precipitation: "0,8 mm",
			iconName: "09d",
			temperature: "20°",
			precipitationValue: 0.8
		),
		HourlyForecastItem(
			timestamp: 4,
			hour: String(localized: "18 Uhr"),
			precipitation: "0 mm",
			iconName: "02d",
			temperature: "21°"
		),
		HourlyForecastItem(
			timestamp: 5,
			hour: String(localized: "22 Uhr"),
			precipitation: "0 mm",
			iconName: "01n",
			temperature: "17°"
		),
	]

	static let gauges: [EnvironmentMetric] = [
		EnvironmentMetric.forAQI(id: "aqi", label: "AQI", value: 18),
		EnvironmentMetric.forUV(value: 6),
		EnvironmentMetric.forPollen(type: .grass, label: String(localized: "Gräser"), value: 22),
		EnvironmentMetric.forAQI(id: "pm25", label: "PM", subscript_: "2.5", value: 14),
		EnvironmentMetric.forAQI(id: "pm10", label: "PM", subscript_: "10", value: 11),
		EnvironmentMetric.forPollen(type: .birch, label: String(localized: "Birke"), value: 4),
		EnvironmentMetric.forAQI(id: "no2", label: "NO", subscript_: "2", value: 9),
	].compactMap { $0 }

	static let climateStripes: [ClimateStripe] = (1940...2026).map { year in
		let progress = Double(year - 1940) / 86.0
		let trend = -0.55 + pow(progress, 2.1) * 2.3
		let jitter = (Double((year * 7919) % 97) / 97.0 - 0.5) * 0.7
		let anomaly = trend + jitter
		return ClimateStripe(year: year, value: 20 + anomaly, anomaly: anomaly)
	}

	struct DailyRow: Identifiable {
		let id: Int
		let weekday: String
		let iconName: String
		let low: Double
		let high: Double
	}

	static let dailyRows: [DailyRow] = [
		("01d", 14.0, 27.0), ("02d", 15, 28), ("10d", 13, 22), ("09d", 12, 19), ("01d", 13, 24),
	].enumerated().map { day, values in
		let date = Calendar.current.date(byAdding: .day, value: day, to: .now) ?? .now
		let weekday = day == 0 ? String(localized: "Heute") : date.formatted(.dateTime.weekday(.abbreviated))
		return DailyRow(id: day, weekday: weekday, iconName: values.0, low: values.1, high: values.2)
	}

	static let dailyTemperatureBounds = (min: 10.0, max: 30.0)
}
