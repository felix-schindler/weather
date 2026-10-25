import Foundation

enum AppGroup {
    static let identifier = "group.weather.schindlerfelix.de"
    nonisolated(unsafe) static let defaults: UserDefaults = UserDefaults(suiteName: identifier) ?? .standard
}
