import SwiftUI

struct DataProviderLink: Identifiable {
	let title: String
	let url: URL
	var id: String { url.absoluteString }
}

struct DataProvider: Identifiable {
	let id: String
	let name: String
	var nameIsLocalized = false
	let title: String
	var titleIsLocalized = false
	let systemImage: String
	let tint: Color
	let about: String
	var license: String? = nil
	let links: [DataProviderLink]
	var sources: [DataProviderLink] = []

	var nameText: Text { nameIsLocalized ? Text(LocalizedStringKey(name)) : Text(verbatim: name) }
	var titleText: Text { titleIsLocalized ? Text(LocalizedStringKey(title)) : Text(verbatim: title) }
}

extension DataProvider {
	static let all: [DataProvider] = [
		DataProvider(
			id: "open-meteo", name: "Open-Meteo", nameIsLocalized: true,
			title: "Open-Meteo", titleIsLocalized: true,
			systemImage: "sun.max.fill", tint: .orange,
			about:
				"Open-Meteo ist eine Open-Source-Wetter-API, die offene Wetterdaten von verschiedenen internationalen Wetterdiensten sammelt. Felix° nutzt als nicht-kommerzielle App den kostenlosen Zugang zu Open-Meteo, unterstützt das Projekt aber mit einer monatlichen Spende von fünf Euro.",
			license: "Attribution 4.0 International (CC BY 4.0)",
			links: [DataProviderLink(title: "open-meteo.com", url: URL(string: "https://open-meteo.com/")!)],
			sources: [
				DataProviderLink(title: "ICON - Deutscher Wetterdienst (DWD)", url: URL(string: "https://www.dwd.de/")!),
				DataProviderLink(title: "GFS & HRRR - NOAA", url: URL(string: "https://www.noaa.gov/")!),
				DataProviderLink(title: "ARPEGE & AROME - Météo-France", url: URL(string: "https://meteofrance.com/")!),
				DataProviderLink(title: "IFS & AIFS - ECMWF", url: URL(string: "https://www.ecmwf.int/")!),
				DataProviderLink(title: "MSM & GSM - JMA", url: URL(string: "https://www.jma.go.jp/")!),
				DataProviderLink(title: "MET Nordic - MET Norway", url: URL(string: "https://www.met.no/")!),
				DataProviderLink(title: "HARMONIE - KNMI", url: URL(string: "https://www.knmi.nl/")!),
				DataProviderLink(title: "HARMONIE - DMI", url: URL(string: "https://www.dmi.dk/")!),
				DataProviderLink(title: "GEM - Canadian Weather Service", url: URL(string: "https://weather.gc.ca/")!),
				DataProviderLink(title: "GFS GRAPES - China Meteorological Administration (CMA)", url: URL(string: "https://www.cma.gov.cn/en/")!),
				DataProviderLink(title: "ACCESS-G - Australian Bureau of Meteorology (BOM)", url: URL(string: "http://www.bom.gov.au/")!),
				DataProviderLink(title: "COSMO 2I & 5M - AM ARPAE ARPAP", url: URL(string: "https://www.arpae.it/it")!),
			]
		),
	]
}
