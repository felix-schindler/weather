import SwiftUI

struct HourlyPlaceholderCard: View {
	var body: some View {
		VStack(spacing: 8) {
			RoundedRectangle(cornerRadius: 3)
				.frame(width: 42, height: 12)
			Circle()
				.frame(width: 35, height: 35)
			RoundedRectangle(cornerRadius: 3)
				.frame(width: 52, height: 9)
			RoundedRectangle(cornerRadius: 3)
				.frame(width: 30, height: 12)
		}
		.foregroundStyle(.secondary.opacity(0.28))
		.frame(width: HourlyForecastCard.contentWidth)
		.frame(maxWidth: .infinity)
		.frame(minHeight: 116)
		.redacted(reason: .placeholder)
		.accessibilityHidden(true)
	}
}
