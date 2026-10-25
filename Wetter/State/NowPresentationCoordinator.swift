import Foundation
import Observation

enum AppTab: Hashable {
    case forecast
    case maps
}

@MainActor
@Observable
final class NowPresentationCoordinator {
    var sheet: NowSheet?
    /// Testing hook (screenshot flows without tapping through the UI):
    /// `-autoPresentMap YES` starts on the map tab.
    var selectedTab: AppTab = UserDefaults.standard.bool(forKey: "autoPresentMap") ? .maps : .forecast {
        didSet {
            guard selectedTab != oldValue else { return }
            if selectedTab != .maps { isLayerPickerPresented = false }
        }
    }

    var isLayerPickerPresented = false
    /// Set by the map when it opens the picker: radar region, model layer, or neither (clouds).
    var selectLayer: (RadarRegion?, WeatherTileLayer?) -> Void = { _, _ in }

    func present(_ sheet: NowSheet) {
        self.sheet = sheet
    }
}
