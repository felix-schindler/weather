import SwiftUI

enum TimeFormatPreference: String, CaseIterable, Identifiable {
	case system
	case h24
	case h12

	var id: String { rawValue }

	var label: LocalizedStringKey {
		switch self {
		case .system:
			return "System"
		case .h24:
			return "24 Stunden"
		case .h12:
			return "12 Stunden"
		}
	}
}
