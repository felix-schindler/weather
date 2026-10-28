//
//  DebugPermissionControls.swift
//  Felix°
//

import CoreLocation
import SwiftUI
import UIKit

struct DebugPermissionControls: View {
	private let locationService = LocationService.shared

	var body: some View {
		VStack(spacing: 8) {
			Text(verbatim: "Permissions")
			row(
				name: "Location",
				status: locationStatusName,
				canPrompt: locationService.authStatus == .notDetermined || locationService.authStatus == nil
			) {
				locationService.requestAuthorization()
			}
		}
		.padding(.bottom, 12)
	}

	private func row(
		name: String,
		status: String,
		canPrompt: Bool,
		request: @escaping () -> Void
	) -> some View {
		HStack(spacing: 12) {
			Text(verbatim: "\(name): \(status)")
			Button {
				if canPrompt {
					request()
				} else if let url = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(url)
				}
			} label: {
				Text(verbatim: canPrompt ? "Request" : "Settings")
			}
			.buttonStyle(.bordered)
		}
	}

	private var locationStatusName: String {
		switch locationService.authStatus {
		case .authorizedAlways: "always"
		case .authorizedWhenInUse: "whenInUse"
		case .denied: "denied"
		case .restricted: "restricted"
		case .notDetermined: "notDetermined"
		case nil: "unknown"
		@unknown default: "unknown"
		}
	}
}
