import SwiftUI

struct NowLayoutPreview: View {
	private let settingsService = SettingService.shared

	var body: some View {
		SkyBand {
			PreviewHead()
				.frame(maxWidth: .infinity)
				.frame(height: 260)
		}
		.animation(.snappy, value: settingsService.headMetrics)
		.accessibilityHidden(true)
	}
}

struct SkyBand<Content: View>: View {
	@ViewBuilder let content: Content

	var body: some View {
		content
			.background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 26))
	}
}

struct PreviewHead: View {
	@Environment(Weather.self) private var weather
	@Environment(Location.self) private var location
	private let settingsService = SettingService.shared

	var body: some View {
		VStack(spacing: 4) {
			Text(location.name)
				.font(.title3.weight(.medium))
				.lineLimit(1)
			Text(roundTemperatureString(temperature: weather.forecast.current?.temperature))
				.font(.system(size: 88, weight: .thin))
			HStack(spacing: 18) {
				ForEach(settingsService.headMetrics) { metric in
					if let value = metric.value(in: weather) {
						Label(value, systemImage: metric.systemImage)
					}
				}
			}
			.font(.subheadline.weight(.medium))
			.lineLimit(1)
			.minimumScaleFactor(0.7)
			.frame(minHeight: 20)
		}
		.foregroundStyle(.primary)
		.padding(.horizontal, 16)
	}
}
