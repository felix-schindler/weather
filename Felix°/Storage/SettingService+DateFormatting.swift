import Foundation

extension SettingService {
	nonisolated static func formattedTime(
		_ date: Date,
		timeZone: TimeZone? = nil,
		showsMinutes: Bool = true
	) -> String {
		date.formatted(style(timeStyle(showsMinutes: showsMinutes), in: timeZone))
	}

	nonisolated static func formattedWeekday(_ date: Date, timeZone: TimeZone) -> String {
		date.formatted(style(.dateTime.weekday(.wide), in: timeZone))
	}

	nonisolated static func formattedDayMonth(_ date: Date, timeZone: TimeZone) -> String {
		date.formatted(style(.dateTime.month(.abbreviated).day(), in: timeZone))
	}

	nonisolated static func formattedShortWeekday(_ date: Date, timeZone: TimeZone) -> String {
		date.formatted(style(.dateTime.weekday(.abbreviated), in: timeZone))
	}

	nonisolated private static func style(
		_ style: Date.FormatStyle,
		in timeZone: TimeZone?
	) -> Date.FormatStyle {
		var style = style
		style.locale = .autoupdatingCurrent
		style.timeZone = timeZone ?? .autoupdatingCurrent
		return style
	}

	nonisolated private static func timeStyle(showsMinutes: Bool) -> Date.FormatStyle {
		switch resolvedTimeFormatPreference {
		case .system:
			return
				showsMinutes
				? Date.FormatStyle(date: .omitted, time: .shortened)
				: .dateTime.hour(.defaultDigits(amPM: .abbreviated))
		case .h24:
			return
				showsMinutes
				? .dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
				: .dateTime.hour(.twoDigits(amPM: .omitted))
		case .h12:
			return
				showsMinutes
				? .dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits)
				: .dateTime.hour(.defaultDigits(amPM: .abbreviated))
		}
	}
}
