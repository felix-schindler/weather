//
//  PermissionSettingsView.swift
//  Felix°
//

import CoreLocation
import SwiftUI
import UIKit

struct PermissionSettingsView: View {
	@Environment(\.openURL) private var openURL
	private let locationService = LocationService.shared

	var body: some View {
		Form {
			Section {
				let locationAuthorized =
					locationService.authStatus == .authorizedAlways
					|| locationService.authStatus == .authorizedWhenInUse
				let locationUndetermined =
					locationService.authStatus == .notDetermined
					|| locationService.authStatus == nil

				Toggle(
					isOn: permissionBinding(
						currentValue: locationAuthorized,
						canPrompt: locationUndetermined,
						request: { locationService.requestAuthorization() },
						settingsURL: URL(string: UIApplication.openSettingsURLString)
					)
				) {
					Label("Standort", systemImage: "location.fill")
						.labelStyle(.settingsIcon(.blue))
				}
			}
		}
		.navigationTitle("Berechtigungen")
		.navigationBarTitleDisplayMode(.inline)
	}

	private func permissionBinding(
		currentValue: Bool,
		canPrompt: Bool,
		request: @escaping () -> Void,
		settingsURL: URL?
	) -> Binding<Bool> {
		Binding(
			get: { currentValue },
			set: { _ in
				if canPrompt {
					request()
				} else if let settingsURL {
					openURL(settingsURL)
				}
			}
		)
	}
}

#Preview {
	NavigationStack {
		PermissionSettingsView()
	}
}
