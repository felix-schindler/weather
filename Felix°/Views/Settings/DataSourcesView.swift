//
//  DataSourcesView.swift
//  Felix°
//

import SwiftUI

struct DataSourcesView: View {
	var body: some View {
		List {
			Section("Wetterdaten") {
				ForEach(DataProvider.all) { provider in
					NavigationLink {
						ProviderAttributionPage(provider: provider)
					} label: {
						ProviderRow(provider: provider)
					}
				}
			}

			Section("Open Source") {
				ForEach(Self.openSourceLinks, id: \.title) { link in
					SettingsExternalLink(destination: URL(string: link.url)!) {
						Label {
							Text(verbatim: link.title)
						} icon: {
							Image(systemName: link.icon)
						}
						.labelStyle(.settingsIcon(link.tint))
					}
				}
			}
		}
		.navigationTitle("Datenquellen & Lizenzen")
		.navigationBarTitleDisplayMode(.inline)
	}

	private static let openSourceLinks: [(title: String, url: String, icon: String, tint: Color)] = [
		("Oscar° (original app)", "https://github.com/strumswell/oscar-weather", "arrow.triangle.branch", .indigo),
		("Icons by Hosein Bagheri", "https://ui8.net/hosein_bagheri/products/3d-weather-icons40", "sparkles", .pink),
		("swift-openapi-generator", "https://github.com/apple/swift-openapi-generator", "swift", .orange),
		("swift-openapi-runtime", "https://github.com/apple/swift-openapi-runtime", "swift", .orange),
		("swift-openapi-urlsession", "https://github.com/apple/swift-openapi-urlsession", "swift", .orange),
	]
}

#Preview {
	NavigationStack {
		DataSourcesView()
	}
}
