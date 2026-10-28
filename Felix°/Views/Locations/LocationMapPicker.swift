//
//  LocationMapPicker.swift
//  Felix°
//
//  Fullscreen map for picking a place, on MapKit: saved cities as emoji pins,
//  a tap anywhere drops the city marker, and the bottom card offers the tapped
//  place for preview/adding.
//

import CoreLocation
import MapKit
import SwiftUI
import UIKit

// MARK: - MapKit map

struct LocationPickerMap: View {
	let chips: [CityMapChip]
	let initialCenter: CLLocationCoordinate2D
	var pickedCoordinate: CLLocationCoordinate2D?
	let onPick: (CLLocationCoordinate2D) -> Void

	/// Country-scale framing around the initial place.
	private var initialRegion: MKCoordinateRegion {
		MKCoordinateRegion(
			center: initialCenter,
			span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
		)
	}

	/// The dot only appears once access exists, so the picker never triggers
	/// the system location prompt.
	private var showsUserLocation: Bool {
		let status = LocationService.shared.authStatus
		return status == .authorizedWhenInUse || status == .authorizedAlways
	}

	var body: some View {
		MapReader { proxy in
			Map(
				initialPosition: .region(initialRegion),
				interactionModes: [.pan, .zoom]
			) {
				ForEach(chips.indices, id: \.self) { index in
					let chip = chips[index]
					Annotation(coordinate: chip.coordinate) {
						CityChip(chip: chip)
					} label: {
						Text(chip.title)
					}
					.annotationTitles(.hidden)
				}

				if let pickedCoordinate {
					Annotation(coordinate: pickedCoordinate) {
						Image(systemName: "mappin.circle.fill")
							.font(.title)
							.symbolRenderingMode(.palette)
							.foregroundStyle(.white, .red)
					} label: {
						Text("Gewählter Punkt")
					}
					.annotationTitles(.hidden)
				}

				if showsUserLocation {
					UserAnnotation()
				}
			}
			.mapStyle(
				.standard(
					elevation: .flat,
					emphasis: .muted,
					pointsOfInterest: .excludingAll,
					showsTraffic: false
				)
			)
			.onTapGesture { point in
				guard let coordinate = proxy.convert(point, from: .local) else { return }
				onPick(coordinate)
			}
		}
	}
}

// MARK: - Chip artwork

private struct CityChip: View {
	let chip: CityMapChip

	var body: some View {
		HStack(spacing: 4) {
			if let emoji = chip.emoji, !emoji.isEmpty {
				Text(emoji)
			}
			if let iconAsset = chip.iconAsset {
				Image(decorative: iconAsset)
					.resizable()
					.scaledToFit()
					.frame(width: 18, height: 18)
			}
			if let temperature = chip.temperature {
				Text("\(Int(temperature.rounded()))°")
					.font(.caption.weight(.semibold))
					.monospacedDigit()
			}
		}
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
		.background(.regularMaterial, in: Capsule())
		.overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
		.shadow(color: .black.opacity(0.25), radius: 3, y: 1)
		.accessibilityLabel(Text(chip.title))
	}
}
