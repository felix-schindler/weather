#if DEBUG

	import SwiftUI

	struct ScreenshotWidgetGallery: View {
		private static let mediumSize = CGSize(width: 364, height: 170)

		var body: some View {
			ZStack {
				LinearGradient(
					colors: [
						Color(hue: 0.65, saturation: 0.55, brightness: 0.35),
						Color(hue: 0.62, saturation: 0.6, brightness: 0.16),
					],
					startPoint: .top,
					endPoint: .bottom
				)
				.ignoresSafeArea()

				dailyWidget
					.frame(width: Self.mediumSize.width, height: Self.mediumSize.height)
					.clipShape(.rect(cornerRadius: 28, style: .continuous))
					.shadow(color: .black.opacity(0.35), radius: 22, y: 12)
					.accessibilityIdentifier("screenshot.widgetGallery.ready")
			}
		}

		private var dailyWidget: some View {
			let days = Self.days
			let minTemp = days.map(\.low).min() ?? 0
			let maxTemp = days.map(\.high).max() ?? 30

			return VStack(alignment: .leading, spacing: 7) {
				Text("Leipzig")
					.font(.headline)
					.fontWeight(.semibold)
					.padding(.bottom, 2)

				ForEach(days.prefix(4), id: \.weekday) { day in
					HStack(spacing: 10) {
						Text(day.weekday)
							.font(.subheadline)
							.fontWeight(.semibold)
							.lineLimit(1)
							.minimumScaleFactor(0.8)
							.frame(width: 48, alignment: .leading)

						Image(systemName: day.icon)
							.symbolRenderingMode(.multicolor)
							.font(.body)
							.frame(width: 30, height: 22)

						Text(roundTemperatureString(temperature: day.low))
							.font(.subheadline)
							.monospacedDigit()
							.foregroundStyle(.white.opacity(0.75))
							.frame(width: 34, alignment: .trailing)

						TemperatureRangeView(
							low: day.low,
							high: day.high,
							focusLow: nil,
							focusHigh: nil,
							minTemp: minTemp,
							maxTemp: maxTemp,
							unit: "°C"
						)
						.frame(height: 6)

						Text(roundTemperatureString(temperature: day.high))
							.font(.subheadline)
							.fontWeight(.semibold)
							.monospacedDigit()
							.frame(width: 34, alignment: .leading)
					}
				}
			}
			.padding(12)
			.foregroundStyle(.white)
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
			.background(
				LinearGradient(colors: [.sunriseStart, .sunnyDayEnd], startPoint: .top, endPoint: .bottom)
			)
		}

		private struct GalleryDay {
			let weekday: String
			let icon: String
			let low: Double
			let high: Double
		}

		private static var days: [GalleryDay] {
			let calendar = Calendar.current
			let today = calendar.startOfDay(for: .now)
			let icons = ["cloud.heavyrain.fill", "cloud.rain.fill", "cloud.sun.fill", "sun.max.fill"]
			let lows: [Double] = [13, 12, 13, 14]
			let highs: [Double] = [16, 19, 22, 24]
			let todayLabel = String(localized: "Heute")
			return (0..<4).map { index in
				let weekday =
					index == 0
					? todayLabel
					: today.addingTimeInterval(Double(index) * 86_400)
						.formatted(Date.FormatStyle().weekday(.abbreviated))
				return GalleryDay(weekday: weekday, icon: icons[index], low: lows[index], high: highs[index])
			}
		}
	}
#endif
