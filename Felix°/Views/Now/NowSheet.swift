import Foundation

enum NowSheet: Identifiable {
	case hourly(Date?)
	case ensemble
	case environment(EnvironmentDetailSection)
	case climate(ClimateSummary)
	case places
	case settings
	case layout

	var id: String {
		switch self {
		case .hourly:
			"hourly"
		case .ensemble:
			"ensemble"
		case .environment(let section):
			"environment-\(section.rawValue)"
		case .climate:
			"climate"  // single instance; the summary payload doesn't affect identity
		case .places:
			"places"
		case .settings:
			"settings"
		case .layout:
			"layout"
		}
	}
}
