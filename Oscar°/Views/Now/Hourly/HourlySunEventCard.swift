import SwiftUI

struct HourlySunEventCard: View {
  let item: HourlySunEventItem

  var body: some View {
    VStack {
      Text(item.time)
        .bold()
        .lineLimit(1)
        .minimumScaleFactor(0.75)
      Image(item.kind.imageName)
        .resizable()
        .scaledToFit()
        .frame(width: 45, height: 45)
        .frame(width: 35, height: 35)
        .accessibilityHidden(true)
      Text(item.weekday)
        .font(.footnote)
        .foregroundStyle(Color.primary.opacity(0.72))
        .lineLimit(1)
        .minimumScaleFactor(0.75)
      Text(verbatim: " ")
        .hidden()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 12)
    .frame(width: HourlyForecastCard.cardWidth)
    .cardBackground()
    .clipShape(.rect(cornerRadius: 10))
    .cardBorder()
    .accessibilityElement(children: .combine)
  }
}
