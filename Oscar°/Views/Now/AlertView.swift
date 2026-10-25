//
//  AlertView.swift
//  Oscar°
//
//  Created by Philipp Bolte on 21.02.22.
//

import SwiftUI

struct AlertView: View {
    @Environment(Weather.self) private var weather: Weather
    @Environment(NowPresentationCoordinator.self) private var presentation

    var body: some View {
        let alerts = weather.alerts.displayInfos
        let tint = alerts.first.map {
            AlertSeverityStyle.color(rank: $0.severityRank, source: $0.source)
        } ?? .orange
        if let top = alerts.first {
            Button {
                presentation.present(.alerts)
            } label: {
                Label(formattedHeadline(top: top, count: alerts.count), systemImage: "exclamationmark.triangle.fill")
            }
            .font(.footnote.weight(.semibold))
            .tint(tint)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityIdentifier("now.alert")
            .accessibilityHint(Text("Öffnet die Wetterwarnungen"))
        }
    }
}

extension AlertView {
    func formattedHeadline(top: WeatherAlertInfo, count: Int) -> String {
        let event = top.event.localizedUppercase
        return count > 1 ? "\(event) (+\(count - 1))" : event
    }
}
