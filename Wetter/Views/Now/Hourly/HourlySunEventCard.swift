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
        Text(verbatim: " ")
          .font(.footnote)
          .hidden()
        Text(item.weekday)
          .lineLimit(1)
          .minimumScaleFactor(0.75)
    }
    .padding(.vertical, 8)
    .frame(width: HourlyForecastCard.cardWidth)
    .accessibilityElement(children: .combine)
  }
}
