import SwiftUI

struct HourlyForecastCard: View {
  let item: HourlyForecastItem
  static let cardWidth: CGFloat = 82

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
        .foregroundStyle(Color.primary.opacity(0.72))
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .opacity(item.precipitationValue > 0 ? 1 : 0)
        .accessibilityHidden(item.precipitationValue <= 0)
      Text(item.temperature)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 12)
    .frame(width: Self.cardWidth)
    .cardBackground()
    .clipShape(.rect(cornerRadius: 10))
    .cardBorder()
    .accessibilityElement(children: .combine)
  }
}
