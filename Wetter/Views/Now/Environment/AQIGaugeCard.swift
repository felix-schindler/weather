//
//  AQIGaugeCard.swift
//  Wetter
//

import SwiftUI

struct AQIGaugeCard: View {
	let metric: EnvironmentMetric

	var body: some View {
		VStack {
			titleText
			Gauge(value: metric.gaugeValue, in: 0...1) {
				EmptyView()
			} currentValueLabel: {
				Text("\(Int(metric.rawValue))")
					.foregroundStyle(metric.color)
			} minimumValueLabel: {
				Text(metric.gaugeMinLabel)
					.foregroundStyle(.secondary)
			} maximumValueLabel: {
				Text(metric.gaugeMaxLabel)
					.foregroundStyle(.secondary)
			}
			.gaugeStyle(.accessoryCircular)
			.tint(metric.gradient)
		}
		.padding(.vertical, 4)
		.frame(minWidth: 72)
	}

	@ViewBuilder private var titleText: some View {
		if let sub = metric.subscriptLabel {
			let base = Text(metric.label).fontWeight(.semibold)
			let subscriptText = Text(sub).font(.caption).fontWeight(.semibold)
			Text("\(base)\(subscriptText)")
		} else {
			Text(LocalizedStringKey(metric.label)).fontWeight(.semibold)
		}
	}
}
