//
//  OnboardingStep.swift
//  Felix°
//

import Foundation

enum OnboardingStep: String, Equatable {
	case location
	case manualLocation
	case notifications
}

extension OnboardingStep {
	/// Returns the notification step when it is worth asking for alerts at
	/// the freshly picked location, or `nil` when onboarding can finish.
	@MainActor
	static func afterLocationResolved(locationService: LocationService) -> OnboardingStep? {
		let notifications = NotificationSettingsManager.shared
		if notifications.authorizationStatus == .notDetermined,
			!notifications.enabled,
			OnboardingRegion.hasAlertCoverage(locationService.knownCoordinates() ?? locationService.getCoordinates())
		{
			return .notifications
		}
		return nil
	}
}
