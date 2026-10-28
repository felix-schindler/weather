import SwiftUI

struct NowSheetView: View {
	let sheet: NowSheet

	@Environment(\.dismiss) private var dismiss

	// The chart pages get a page-sized sheet on iPad, the Duo's inner
	// display and Mac; iPhone sheets ignore the sizing.
	var body: some View {
		switch sheet {
		case .hourly(let target):
			HourlyDetailView(initialTarget: target)
				.presentationSizing(.page)
		case .ensemble:
			// Wide layouts open it straight from 12-Tage; on iPhone it's pushed
			// from the hourly sheet instead.
			NavigationStack {
				EnsembleView(initialDate: .now)
					.toolbar {
						ToolbarItem(placement: .topBarTrailing) {
							Button(role: .close) { dismiss() }
						}
					}
			}
			.presentationSizing(.page)
		case .environment(let section):
			EnvironmentDetailView(scrollTo: section)
				.presentationSizing(.page)
		case .climate(let summary):
			ClimateDetailView(summary: summary)
				.presentationSizing(.page)
		case .places:
			LocationsView()
				.presentationSizing(.page)
		case .settings:
			SettingsView()
				.presentationSizing(.page)
		case .layout:
			NowLayoutSheet()
				.presentationSizing(.page)
		}
	}
}
