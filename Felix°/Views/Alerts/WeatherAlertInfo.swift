import Foundation

struct WeatherAlertInfo: Identifiable {
	let id: String
	let event: String
	let severityRank: Int
	let headline: String?
	let details: String?
	let instruction: String?
	let onset: Date?
	let expires: Date?
}

extension [WeatherAlertInfo] {
	func sortedForDisplay(now: Date = Date()) -> [WeatherAlertInfo] {
		sorted {
			let l = Swift.max(0, $0.onset?.timeIntervalSince(now) ?? 0)
			let r = Swift.max(0, $1.onset?.timeIntervalSince(now) ?? 0)
			return l != r ? l < r : $0.severityRank > $1.severityRank
		}
	}
}
