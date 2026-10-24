//
//  ClassicHeroArt.swift
//  Oscar°
//
//  The weather icon above the top edge of the iOS 6 card, and the small icon
//  used in the hourly strip and day rows.
//

import SwiftUI

struct ClassicHeroArt: View {
    let weatherCode: Double
    let isDay: Bool
    let latitude: Double
    let width: CGFloat
    var cloudScale: CGFloat = 1

    private var scale: CGFloat { width / 288 }

    private var symbol: String {
        switch weatherCode {
        case 0, 1: isDay ? "sun.max.fill" : "moon.stars.fill"
        case 2: isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case 3: "cloud.fill"
        case 45, 48: "cloud.fog.fill"
        case 71...77, 85, 86: "cloud.snow.fill"
        case 95...99: "cloud.bolt.rain.fill"
        default: "cloud.rain.fill"
        }
    }

    var body: some View {
        Image(systemName: symbol)
            .symbolRenderingMode(.multicolor)
            .font(.system(size: 64 * scale * cloudScale))
            .frame(width: width, height: 110 * scale)
            .accessibilityHidden(true)
    }
}

#Preview {
    VStack(spacing: 30) {
        ClassicHeroArt(weatherCode: 1, isDay: true, latitude: 52, width: 360)
        ClassicHeroArt(weatherCode: 2, isDay: true, latitude: 52, width: 360)
        ClassicHeroArt(weatherCode: 61, isDay: true, latitude: 52, width: 360)
        ClassicHeroArt(weatherCode: 1, isDay: false, latitude: 52, width: 360)
    }
    .background(Color(red: 0.12, green: 0.2, blue: 0.38))
}
