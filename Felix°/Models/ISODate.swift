import Foundation

enum ISODate {
	nonisolated(unsafe) private static let fractional: ISO8601DateFormatter = {
		let f = ISO8601DateFormatter()
		f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return f
	}()
	nonisolated(unsafe) private static let plain: ISO8601DateFormatter = {
		let f = ISO8601DateFormatter()
		f.formatOptions = [.withInternetDateTime]
		return f
	}()

	static func parse(_ string: String) -> Date? {
		fractional.date(from: string)
			?? plain.date(from: string)
			?? Double(string).map { Date(timeIntervalSince1970: $0) }
	}
}
