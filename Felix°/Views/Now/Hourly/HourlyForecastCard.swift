import SwiftUI

struct HourlyForecastCard: View {
	let item: HourlyForecastItem
	static let cardWidth: CGFloat = 82
	static let contentWidth: CGFloat = 48

	var body: some View {
		VStack {
			Text(item.hour)
				.bold()
				.lineLimit(1)
				.minimumScaleFactor(0.75)
			Image(item.iconName)
				.resizable()
				.scaledToFit()
				.frame(width: 35, height: 35)
				.accessibilityHidden(true)
			Text(item.precipitation)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.lineLimit(1)
				.minimumScaleFactor(0.75)
				.opacity(item.precipitationValue > 0 ? 1 : 0)
				.accessibilityHidden(item.precipitationValue <= 0)
			Text(item.temperature)
				.lineLimit(1)
				.minimumScaleFactor(0.75)
		}
		.frame(width: Self.contentWidth)
		.frame(width: Self.cardWidth, alignment: .leading)
		.accessibilityElement(children: .combine)
	}
}
