import Foundation

enum WindSpeedUnit: String {
	case kmh
	case ms
	case mph
	case kn
	case bft

	init(settingValue: String?) {
		self = WindSpeedUnit(rawValue: settingValue ?? "") ?? .kmh
	}

	var apiRawValue: String {
		switch self {
		case .bft:
			return WindSpeedUnit.kmh.rawValue
		default:
			return rawValue
		}
	}

	var displayUnit: String {
		switch self {
		case .kmh:
			return "km/h"
		case .ms:
			return "m/s"
		case .mph:
			return "mph"
		case .kn:
			return "kn"
		case .bft:
			return "Bft"
		}
	}

	var usesBeaufortDisplay: Bool {
		self == .bft
	}
}

enum BeaufortScale {
	static func force(forKilometersPerHour speed: Double) -> Int {
		switch max(0, speed) {
		case ..<1:
			return 0
		case ..<6:
			return 1
		case ..<12:
			return 2
		case ..<20:
			return 3
		case ..<29:
			return 4
		case ..<39:
			return 5
		case ..<50:
			return 6
		case ..<62:
			return 7
		case ..<75:
			return 8
		case ..<89:
			return 9
		case ..<103:
			return 10
		case ..<118:
			return 11
		default:
			return 12
		}
	}

	static func value(forKilometersPerHour speed: Double?) -> Double? {
		guard let speed else { return nil }
		return Double(force(forKilometersPerHour: speed))
	}

	static func convertedValues(fromKilometersPerHour values: [Double]) -> [Double] {
		values.map { Double(force(forKilometersPerHour: $0)) }
	}

	static func convertedValues(fromKilometersPerHour values: [Double?]) -> [Double?] {
		values.map { value(forKilometersPerHour: $0) }
	}
}

enum WindSpeedFormatter {
	static func string(_ value: Double?, unit: String) -> String {
		guard let value else { return "--" }
		if unit == WindSpeedUnit.bft.displayUnit {
			return "\(Int(value.rounded())) \(unit)"
		}
		return "\(value.formatted(.number.precision(.fractionLength(1)))) \(unit)"
	}
}
