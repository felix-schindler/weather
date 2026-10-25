//
//  OnboardingView.swift
//  Wetter
//

import SwiftUI

struct OnboardingView: View {
	@Environment(\.accessibilityReduceMotion) private var reduceMotion
	@State private var step: OnboardingStep = ScreenshotMode.onboardingStep ?? .location
	private let coordinator = OnboardingCoordinator.shared
	private let locationService = LocationService.shared

	var body: some View {
		GeometryReader { proxy in
			let layout = OnboardingLayout(size: proxy.size)
			ZStack {
				Color(.systemBackground)
					.ignoresSafeArea()

				if layout.isPad {
					RoundedRectangle(cornerRadius: OnboardingMetrics.cornerRadius)
						.fill(.regularMaterial)
						.frame(width: layout.cardFrame.width, height: layout.cardFrame.height)
						.shadow(color: .black.opacity(0.25), radius: 30, y: 16)
				}

				content
					.id(step)
					.transition(.onboardingSlide(reduceMotion: reduceMotion))
			}
			.environment(\.onboardingLayout, layout)
		}
	}

	@ViewBuilder private var content: some View {
		switch step {
		case .location:
			OnboardingLocationStep { granted in
				if granted {
					advance(to: .afterLocationResolved(locationService: locationService))
				} else {
					advance(to: .manualLocation)
				}
			}
		case .manualLocation:
			OnboardingManualLocationStep {
				advance(to: .afterLocationResolved(locationService: locationService))
			}
		case .notifications:
			OnboardingNotificationsStep { coordinator.complete() }
		}
	}

	/// Advances to the next step, or finishes onboarding when there is none.
	private func advance(to next: OnboardingStep?) {
		guard let next else {
			coordinator.complete()
			return
		}
		withAnimation(.smooth(duration: 0.6)) {
			step = next
		}
	}
}

#Preview {
	OnboardingView()
		.environment(Weather.mock)
		.environment(Location())
		.preferredColorScheme(.dark)
}
