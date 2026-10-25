//
//  WetterWidgetsBundle.swift
//  WetterWidgetsBundle
//
//  Created by Philipp Bolte on 25.10.20.
//

import WidgetKit
import SwiftUI

@main
struct WetterWidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        #if os(iOS)
        RadarWidget()
        NowTodayWidget()
        DailyForecastWidget()
        GlobalRadarWidget()
        RainRadarLiveActivityWidget()
        #endif
        TemperatureLockScreenWidget()
        PrecipitationLockScreenWidget()
        RainTimelineLockScreenWidget()
        UVIndexLockScreenWidget()
        WindLockScreenWidget()
    }
}
