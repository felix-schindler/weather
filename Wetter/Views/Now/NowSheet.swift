import Foundation

enum NowSheet: Identifiable {
	case hourly(Date?)
	case ensemble
	case environment(EnvironmentDetailSection)
	case climate(ClimateSummary)
	case stations(String)
	case alerts
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
		case .stations:
			"stations"  // the chips switch stations inside one sheet
		case .alerts:
			"alerts"
		case .places:
			"places"
		case .settings:
			"settings"
		case .layout:
			"layout"
		}
	}
}
