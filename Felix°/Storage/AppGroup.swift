import Foundation

enum AppGroup {
	static let identifier = "group.de.schindlerfelix.weather"
	nonisolated(unsafe) static let defaults: UserDefaults = UserDefaults(suiteName: identifier) ?? .standard
}
