//
//  Color-Custom.swift
//  Felix°
//
//  Created by Paul Hudson on 16/11/2021.
//

import SwiftUI

extension Color {
	static let sunriseStart = Color(hue: 0.62, saturation: 0.6, brightness: 0.42)
	static let sunnyDayEnd = Color(hue: 0.6, saturation: 0.4, brightness: 0.85)
}

extension Color {
	// Series colors tuned for dark material need a darker twin on light material.
	static func adaptiveGray(dark: Double, light: Double) -> Color {
		#if os(watchOS)
			Color(white: dark)
		#else
			Color(
				uiColor: UIColor { traits in
					UIColor(white: traits.userInterfaceStyle == .dark ? dark : light, alpha: 1)
				})
		#endif
	}
}
