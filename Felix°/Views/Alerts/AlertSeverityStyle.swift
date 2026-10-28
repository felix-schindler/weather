import SwiftUI

enum AlertSeverityStyle {
	static let sourceName = "Environment Canada"

	static func color(rank: Int) -> Color {
		switch rank {
		case 2: .orange
		case 3: .red
		case 4: .purple
		default: .yellow
		}
	}

	static func label(rank: Int) -> LocalizedStringKey {
		switch rank {
		case 1: "Minor"
		case 2: "Moderate"
		case 3: "Severe"
		case 4: "Extreme"
		default: "Alert"
		}
	}
}
