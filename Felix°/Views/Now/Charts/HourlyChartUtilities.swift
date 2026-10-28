import Charts
import Foundation
import SwiftUI

extension Binding where Value == Date? {
	static func snapped(to interval: TimeInterval, _ source: Binding<Date?>) -> Binding<Date?> {
		Binding(
			get: { source.wrappedValue },
			set: { newValue in
				let snapped = newValue.map { date in
					Date(timeIntervalSince1970: (date.timeIntervalSince1970 / interval).rounded() * interval)
				}
				if snapped != source.wrappedValue {
					source.wrappedValue = snapped
				}
			}
		)
	}
}

enum ChartScale {
	/// Rounds a raw axis step up to the next 1/2/5 × 10ⁿ, the usual "nice" gridline.
	static func niceStep(_ raw: Double) -> Double {
		let magnitude = pow(10, floor(log10(max(raw, 0.0001))))
		let normalized = raw / magnitude
		if normalized < 1.5 { return magnitude }
		if normalized < 3.5 { return 2 * magnitude }
		if normalized < 7.5 { return 5 * magnitude }
		return 10 * magnitude
	}
}

enum HourlyChartUtilities {
	static func dayChangeIndices(time: [Double], calendar: Calendar = .current) -> [Int] {
		guard time.count > 1 else { return [] }

		return time.indices.dropFirst().filter { index in
			let previousDate = Date(timeIntervalSince1970: time[index - 1])
			let currentDate = Date(timeIntervalSince1970: time[index])
			return !calendar.isDate(previousDate, inSameDayAs: currentDate)
		}
	}

	static func dayAbbreviation(from date: Date) -> String {
		date.formatted(.dateTime.weekday(.abbreviated))
	}

	static func hourString(from date: Date) -> String {
		SettingService.formattedTime(date, showsMinutes: false)
	}
}

extension HourlyChartUtilities {
	@ChartContentBuilder
	static func daySeparatorMarks(time: [Double]) -> some ChartContent {
		ForEach(dayChangeIndices(time: time), id: \.self) { index in
			RuleMark(x: .value("Hour", Date(timeIntervalSince1970: time[index])))
				.foregroundStyle(.gray.opacity(0.6))
				.lineStyle(StrokeStyle(lineWidth: 1.5, dash: [8, 4]))
				.annotation(
					position: .topTrailing,
					spacing: 8,
					overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))
				) {
					ChartDaySeparatorLabel(text: dayAbbreviation(from: Date(timeIntervalSince1970: time[index])))
				}
		}
	}

	@ChartContentBuilder
	static func currentPointMark(x: Date, series: String, value: Double) -> some ChartContent {
		PointMark(x: .value("Current Hour", x), y: .value(series, value))
			.symbol(.circle)
			.symbolSize(90)
			.foregroundStyle(.black)

		PointMark(x: .value("Current Hour", x), y: .value(series, value))
			.symbol(.circle)
			.symbolSize(42)
			.foregroundStyle(.white)
	}

	@AxisContentBuilder
	static func sixHourAxisMarks() -> some AxisContent {
		AxisMarks(values: .stride(by: .hour, count: 6)) { value in
			AxisValueLabel {
				if let date = value.as(Date.self) {
					Text(hourString(from: date))
				}
			}
			AxisGridLine()
			AxisTick()
		}
	}
}

struct ChartReadoutRow {
	let label: String
	let value: String
	let color: Color
}

/// The scrub readout used by every chart that shows values while the finger is down.
///
/// Chart annotations don't get a backdrop to blur, so a material background there
/// leaves the labels sitting straight on the plot's grid and lines — unreadable in
/// light mode, where that ink is dark too. The readout therefore paints its own
/// surface, resolved from the color scheme it renders in so text and background
/// can never disagree. Layout and typography mirror `HourlyReadoutBox`.
struct ChartReadoutView: View {
	private struct Row: Identifiable {
		let id: Int
		let color: Color
		let label: String
		let value: String
	}

	private let time: String
	private let rows: [Row]

	init(time: String, items: [ChartReadoutRow]) {
		self.time = time
		self.rows = items.enumerated().map { Row(id: $0.offset, color: $0.element.color, label: $0.element.label, value: $0.element.value) }
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 3) {
			Text(verbatim: time)
				.font(.caption2.weight(.medium).monospacedDigit())
				.foregroundStyle(Color.primary.opacity(0.65))
				.padding(.bottom, 1)

			ForEach(rows) { row in
				HStack(spacing: 5) {
					Circle()
						.fill(row.color)
						.frame(width: 6, height: 6)

					Text(verbatim: row.label)
						.foregroundStyle(Color.primary.opacity(0.75))

					Text(verbatim: row.value)
						.foregroundStyle(.primary)
				}
			}
		}
		.font(.caption2.weight(.semibold).monospacedDigit())
		.padding(8)
		.background(Color(uiColor: .systemBackground))
		.clipShape(.rect(cornerRadius: 8))
		.shadow(radius: 4)
	}
}

/// Weekday label pinned to the day separator lines.
///
/// It sits in a chart annotation too, so it can't lean on a material capsule:
/// without a backdrop the material leaves the text bare on the plot in light mode.
struct ChartDaySeparatorLabel: View {
	let text: String

	var body: some View {
		Text(verbatim: text)
			.font(.caption.weight(.medium))
			.foregroundStyle(Color.primary.opacity(0.7))
			.padding(.horizontal, 6)
			.padding(.vertical, 2)
			.background(Color(uiColor: .systemBackground), in: .capsule)
	}
}

struct ChartLegendView: View {
	let items: [(label: String, color: Color)]
	var minimumItemWidth: CGFloat = 74

	var body: some View {
		LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumItemWidth), spacing: 12)], alignment: .leading, spacing: 8) {
			ForEach(items.enumerated(), id: \.offset) { _, item in
				HStack(spacing: 6) {
					Circle()
						.fill(item.color)
						.frame(width: 8, height: 8)

					Text(verbatim: item.label)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
		}
	}
}
