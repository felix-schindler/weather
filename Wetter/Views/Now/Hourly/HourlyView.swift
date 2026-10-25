//
//  HourlyView.swift
//  Wetter
//
//  Created by Philipp Bolte on 24.10.20.
//

import SwiftUI

struct HourlyView: View {
  @Environment(Weather.self) private var weather: Weather
  @Environment(NowPresentationCoordinator.self) private var presentation
  @Binding private var visibleDayLabel: String?
  @State private var leadingItemID: String?

  init(visibleDayLabel: Binding<String?> = .constant(nil)) {
    _visibleDayLabel = visibleDayLabel
  }

  private var items: [HourlyTimelineItem] {
    HourlyForecastBuilder.makeItems(
      forecast: weather.forecast,
      precipSeries: weather.precipSeries,
      isLoading: weather.isLoading
    )
  }

  private var hasHourlyDetailData: Bool {
    HourlyForecastBuilder.hasHourlyDetailData(forecast: weather.forecast)
  }

  var body: some View {
    let items = self.items
    let shouldShowPlaceholders = weather.isLoading && items.isEmpty
    let timeZone = weather.forecast.locationTimeZone
    let now = Date(timeIntervalSince1970: weather.forecast.current?.time ?? 0)
    let leadingItem = items.first { $0.id == leadingItemID } ?? items.first
    let dayLabel = leadingItem.map {
      HourlyFormatting.dayLabel(timestamp: $0.timestamp, timeZone: timeZone, now: now)
    }

    ScrollView(.horizontal) {
      LazyHStack(spacing: 12) {
        if shouldShowPlaceholders {
          ForEach(0..<10, id: \.self) { _ in
            HourlyPlaceholderCard()
              .padding(.vertical, 4)
          }
        } else {
          ForEach(items) { item in
            timelineItemView(item)
              .padding(.vertical, 4)
              .onTapGesture {
                presentDetails(at: Date(timeIntervalSince1970: item.timestamp))
              }
          }
        }
      }
      .scrollTargetLayout()
    }
    .scrollIndicators(.hidden)
    .scrollTargetBehavior(.viewAligned(limitBehavior: .never))
    .scrollPosition(id: $leadingItemID)
    .contentMargins(.trailing, 16, for: .scrollContent)
    .frame(maxWidth: .infinity)
    .contentShape(.rect)
    .onTapGesture(perform: presentDetails)
    .disabled(!hasHourlyDetailData)
    .accessibilityAction(named: Text("Stündliche Details"), presentDetails)
    .accessibilityIdentifier("now.hourly")
    .onChange(of: dayLabel, initial: true) { _, label in
      guard visibleDayLabel != label else { return }
      visibleDayLabel = label
    }
  }

  private func timelineItemView(_ item: HourlyTimelineItem) -> some View {
    VStack(spacing: 0) {
      switch item {
      case .forecast(let forecast):
        HourlyForecastCard(item: forecast)
      case .sunEvent(let sunEvent):
        HourlySunEventCard(item: sunEvent)
      }
    }
  }

  private func presentDetails() {
    presentDetails(at: nil)
  }

  private func presentDetails(at target: Date?) {
    guard hasHourlyDetailData else {
      return
    }

    presentation.present(.hourly(target))
  }
}

#Preview {
  HourlyView()
    .frame(height: 200)
    .environment(Weather.mock)
    .environment(NowPresentationCoordinator())
}
