//
//  Color-Custom.swift
//  Oscar°
//
//  Created by Paul Hudson on 16/11/2021.
//

import SwiftUI

extension Color {
    init(hex: Int, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 8)  & 0xff) / 255,
            blue:  Double( hex        & 0xff) / 255,
            opacity: alpha
        )
    }

    static let midnightStart = Color(hue: 0.66, saturation: 0.8, brightness: 0.1)
    static let midnightEnd = Color(hue: 0.62, saturation: 0.5, brightness: 0.33)
    static let sunriseStart = Color(hue: 0.62, saturation: 0.6, brightness: 0.42)
    static let sunnyDayStart = Color(hue: 0.6, saturation: 0.6, brightness: 0.6)
    static let sunnyDayEnd = Color(hue: 0.6, saturation: 0.4, brightness: 0.85)
}

private struct AdaptiveTextShadow: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let opacity: Double
    let radius: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content.shadow(
            color: colorScheme == .dark ? .black.opacity(opacity) : .clear,
            radius: radius,
            y: y
        )
    }
}

extension View {
    // White text needs the shadow on dark material; dark text would only get a halo.
    func adaptiveShadow(opacity: Double = 0.3, radius: CGFloat, y: CGFloat = 1) -> some View {
        modifier(AdaptiveTextShadow(opacity: opacity, radius: radius, y: y))
    }
}

extension Color {
    // Series colors tuned for dark material need a darker twin on light material.
    static func adaptiveGray(dark: Double, light: Double) -> Color {
        #if os(watchOS)
        Color(white: dark)
        #else
        Color(uiColor: UIColor { traits in
            UIColor(white: traits.userInterfaceStyle == .dark ? dark : light, alpha: 1)
        })
        #endif
    }
}
