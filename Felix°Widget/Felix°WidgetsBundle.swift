//
//  FelixWidgetsBundle.swift
//  FelixWidgetsBundle
//
//  Created by Philipp Bolte on 25.10.20.
//

import SwiftUI
import WidgetKit

@main
struct FelixWidgetsBundle: WidgetBundle {
	@WidgetBundleBuilder
	var body: some Widget {
		#if os(iOS)
			NowTodayWidget()
			DailyForecastWidget()
		#endif
		TemperatureLockScreenWidget()
		PrecipitationLockScreenWidget()
		UVIndexLockScreenWidget()
		WindLockScreenWidget()
	}
}
