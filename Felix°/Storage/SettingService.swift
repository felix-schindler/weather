import CoreData
import OSLog
import SwiftUI
import WidgetKit

@MainActor
@Observable
final class SettingService {
	static let shared = SettingService()
	private static let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier ?? "Felix°",
		category: "Storage"
	)
	var temperatureUnit: String {
		didSet { unitDidChange(key: Self.temperatureUnitKey, value: temperatureUnit) }
	}
	var windSpeedUnit: String {
		didSet { unitDidChange(key: Self.windSpeedUnitKey, value: windSpeedUnit) }
	}
	var precipitationUnit: String {
		didSet { unitDidChange(key: Self.precipitationUnitKey, value: precipitationUnit) }
	}
	var sectionArrangementsRaw: [String: Data] {
		didSet { UserDefaults.standard.set(sectionArrangementsRaw, forKey: "sectionArrangements") }
	}
	var nowSectionOrderRaw: [String]? {
		didSet { UserDefaults.standard.set(nowSectionOrderRaw, forKey: "nowSectionOrder") }
	}
	var hiddenNowSectionsRaw: [String]? {
		didSet { UserDefaults.standard.set(hiddenNowSectionsRaw, forKey: "hiddenNowSections") }
	}
	var stageNowSectionsRaw: [String]? {
		didSet { UserDefaults.standard.set(stageNowSectionsRaw, forKey: "stageNowSections") }
	}
	var headMetricOrderRaw: [String]? {
		didSet { UserDefaults.standard.set(headMetricOrderRaw, forKey: "headMetricOrder") }
	}
	var hiddenHeadMetricsRaw: [String]? {
		didSet { UserDefaults.standard.set(hiddenHeadMetricsRaw, forKey: "hiddenHeadMetrics") }
	}
	var timeFormatPreference: TimeFormatPreference {
		didSet {
			Self.defaults.set(timeFormatPreference.rawValue, forKey: Self.timeFormatPreferenceKey)
			nc.post(name: .weatherRefreshNeeded, object: nil)
		}
	}
	var dailyForecastDaytimeTemperaturesEnabled: Bool {
		didSet {
			Self.defaults.set(dailyForecastDaytimeTemperaturesEnabled, forKey: Self.dailyForecastDaytimeTemperaturesEnabledKey)
		}
	}
	var dailyForecastDaytimeTemperatureDisplayMode: ForecastDaytimeTemperatureDisplayMode {
		didSet {
			Self.defaults.set(dailyForecastDaytimeTemperatureDisplayMode.rawValue, forKey: Self.dailyForecastDaytimeTemperatureDisplayModeKey)
		}
	}
	var dailyForecastDaytimeTemperatureRangeMode: ForecastDaytimeTemperatureRangeMode {
		didSet {
			Self.defaults.set(dailyForecastDaytimeTemperatureRangeMode.rawValue, forKey: Self.dailyForecastDaytimeTemperatureRangeModeKey)
		}
	}
	var dailyForecastDaytimeCustomStartHour: Int {
		didSet {
			let clamped = Self.clampedHour(dailyForecastDaytimeCustomStartHour)
			if clamped != dailyForecastDaytimeCustomStartHour {
				dailyForecastDaytimeCustomStartHour = clamped
				return
			}
			if dailyForecastDaytimeCustomEndHour < clamped {
				dailyForecastDaytimeCustomEndHour = clamped
			}
			Self.defaults.set(clamped, forKey: Self.dailyForecastDaytimeCustomStartHourKey)
		}
	}
	var dailyForecastDaytimeCustomEndHour: Int {
		didSet {
			let clamped = Self.clampedHour(dailyForecastDaytimeCustomEndHour)
			if clamped != dailyForecastDaytimeCustomEndHour {
				dailyForecastDaytimeCustomEndHour = clamped
				return
			}
			if dailyForecastDaytimeCustomStartHour > clamped {
				dailyForecastDaytimeCustomStartHour = clamped
			}
			Self.defaults.set(clamped, forKey: Self.dailyForecastDaytimeCustomEndHourKey)
		}
	}
	var forecastModelPreference: ForecastModelPreference {
		didSet {
			Self.defaults.set(forecastModelPreference.rawValue, forKey: Self.forecastModelPreferenceKey)
			nc.post(name: .weatherRefreshNeeded, object: nil)
		}
	}
	private let nc = NotificationCenter.default
	nonisolated private static let timeFormatPreferenceKey = "timeFormatPreference"
	private static let dailyForecastDaytimeTemperaturesEnabledKey = "dailyForecastDaytimeTemperaturesEnabled"
	private static let dailyForecastDaytimeTemperatureDisplayModeKey = "dailyForecastDaytimeTemperatureDisplayMode"
	private static let dailyForecastDaytimeTemperatureRangeModeKey = "dailyForecastDaytimeTemperatureRangeMode"
	private static let dailyForecastDaytimeCustomStartHourKey = "dailyForecastDaytimeCustomStartHour"
	private static let dailyForecastDaytimeCustomEndHourKey = "dailyForecastDaytimeCustomEndHour"
	nonisolated private static let forecastModelPreferenceKey = "forecastModelPreference"
	nonisolated private static let temperatureUnitKey = "temperatureUnit"
	nonisolated private static let windSpeedUnitKey = "windSpeedUnit"
	nonisolated private static let precipitationUnitKey = "precipitationUnit"
	nonisolated private static var defaults: UserDefaults { AppGroup.defaults }

	private init() {
		Self.migrateUnitsFromCoreDataIfNeeded()
		temperatureUnit = Self.resolvedTemperatureUnit
		windSpeedUnit = Self.resolvedWindSpeedUnit
		precipitationUnit = Self.resolvedPrecipitationUnit
		sectionArrangementsRaw = UserDefaults.standard.dictionary(forKey: "sectionArrangements") as? [String: Data] ?? [:]
		nowSectionOrderRaw = UserDefaults.standard.stringArray(forKey: "nowSectionOrder")
		hiddenNowSectionsRaw = UserDefaults.standard.stringArray(forKey: "hiddenNowSections")
		stageNowSectionsRaw = UserDefaults.standard.stringArray(forKey: "stageNowSections")
		headMetricOrderRaw = UserDefaults.standard.stringArray(forKey: "headMetricOrder")
		hiddenHeadMetricsRaw = UserDefaults.standard.stringArray(forKey: "hiddenHeadMetrics")
		timeFormatPreference =
			TimeFormatPreference(
				rawValue: Self.defaults.string(forKey: Self.timeFormatPreferenceKey) ?? ""
			) ?? .system
		dailyForecastDaytimeTemperaturesEnabled = Self.defaults.bool(
			forKey: Self.dailyForecastDaytimeTemperaturesEnabledKey
		)
		dailyForecastDaytimeTemperatureDisplayMode =
			ForecastDaytimeTemperatureDisplayMode(
				rawValue: Self.defaults.string(
					forKey: Self.dailyForecastDaytimeTemperatureDisplayModeKey
				) ?? ""
			) ?? .replaceValues
		dailyForecastDaytimeTemperatureRangeMode =
			ForecastDaytimeTemperatureRangeMode(
				rawValue: Self.defaults.string(
					forKey: Self.dailyForecastDaytimeTemperatureRangeModeKey
				) ?? ""
			) ?? .sunriseSunset
		dailyForecastDaytimeCustomStartHour =
			Self.defaults.object(
				forKey: Self.dailyForecastDaytimeCustomStartHourKey
			) == nil
			? 9
			: Self.clampedHour(
				Self.defaults.integer(forKey: Self.dailyForecastDaytimeCustomStartHourKey)
			)
		dailyForecastDaytimeCustomEndHour =
			Self.defaults.object(
				forKey: Self.dailyForecastDaytimeCustomEndHourKey
			) == nil
			? 18
			: Self.clampedHour(
				Self.defaults.integer(forKey: Self.dailyForecastDaytimeCustomEndHourKey)
			)
		forecastModelPreference =
			ForecastModelPreference(
				rawValue: Self.defaults.string(forKey: Self.forecastModelPreferenceKey) ?? ""
			) ?? .bestMatch
	}

	private func unitDidChange(key: String, value: String) {
		Self.defaults.set(value, forKey: key)
		nc.post(name: .weatherRefreshNeeded, object: nil)
		WidgetCenter.shared.reloadAllTimelines()
	}

	private static func migrateUnitsFromCoreDataIfNeeded() {
		guard defaults.string(forKey: temperatureUnitKey) == nil else { return }
		let context = PersistenceController.shared.container.viewContext
		guard let stored = try? context.fetch(Settings.fetchRequest()).first else { return }
		defaults.set(stored.temperatureUnit ?? "celsius", forKey: temperatureUnitKey)
		defaults.set(stored.windSpeedUnit ?? "kmh", forKey: windSpeedUnitKey)
		defaults.set(stored.precipitationUnit ?? "mm", forKey: precipitationUnitKey)
	}

	nonisolated static var resolvedTimeFormatPreference: TimeFormatPreference {
		let rawValue = defaults.string(forKey: timeFormatPreferenceKey)
		return TimeFormatPreference(rawValue: rawValue ?? "") ?? .system
	}

	nonisolated static var resolvedForecastModelPreference: ForecastModelPreference {
		let rawValue = defaults.string(forKey: forecastModelPreferenceKey)
		return ForecastModelPreference(rawValue: rawValue ?? "") ?? .bestMatch
	}

	nonisolated static var resolvedTemperatureUnit: String {
		defaults.string(forKey: temperatureUnitKey) ?? "celsius"
	}

	nonisolated static var resolvedWindSpeedUnit: String {
		defaults.string(forKey: windSpeedUnitKey) ?? "kmh"
	}

	nonisolated static var resolvedPrecipitationUnit: String {
		defaults.string(forKey: precipitationUnitKey) ?? "mm"
	}

	private static func clampedHour(_ hour: Int) -> Int {
		min(max(hour, 0), 23)
	}

}
