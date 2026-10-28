//
//  AlertListView.swift
//  Felix°
//
//  Created by Philipp Bolte on 01.12.21.
//

import SwiftUI

struct AlertListView: View {
	@Environment(Weather.self) private var weather: Weather

	var body: some View {
		AlertInfoSheet(alerts: weather.alerts.displayInfos)
	}
}

extension AlertResponse {
	var displayInfos: [WeatherAlertInfo] {
		let infos: [WeatherAlertInfo] =
			switch self {
			case .canadian(let canadianAlerts):
				canadianAlerts
					.flatMap { $0.alert?.alerts ?? [] }
					.map(WeatherAlertInfo.init(canadianAlert:))
			}
		return infos.sortedForDisplay()
	}
}

extension WeatherAlertInfo {
	init(
		canadianAlert alert: Operations.getCanadianWeatherAlerts.Output.Ok.Body.jsonPayloadPayload
			.alertPayload.alertsPayloadPayload
	) {
		let banner = alert.alertBannerText ?? String(localized: "Wetterwarnung")
		id = alert.alertId ?? "\(banner)-\(alert.eventOnsetTime ?? "")"
		event = banner
		severityRank =
			switch (alert._type ?? "").lowercased() {
			case "warning": 3
			case "watch": 2
			default: 1
			}
		headline = nil
		details = alert.text
		instruction = nil
		onset = Self.parseISO8601(alert.eventOnsetTime)
		expires = Self.parseISO8601(alert.eventEndTime)
	}

	private static func parseISO8601(_ string: String?) -> Date? {
		string.flatMap(ISODate.parse)
	}
}
