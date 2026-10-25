//
//  LocationMapPicker.swift
//  Oscar°
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

    /// Country-scale framing around the initial place, close to the weather
    /// map's default zoom 7.
    private var initialRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: initialCenter,
            span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
        )
    }

    /// The dot only appears once access exists, so the picker never triggers
    /// the system location prompt.
    private var showsUserLocation: Bool { WeatherMapView.locationAuthorized }

    var body: some View {
        MapReader { proxy in
            Map(
                initialPosition: .region(initialRegion),
                interactionModes: [.pan, .zoom]
            ) {
                ForEach(chips.indices, id: \.self) { index in
                    let chip = chips[index]
                    Annotation(coordinate: chip.coordinate) {
                        Image(uiImage: CityChipArtwork.image(for: chip))
                    } label: {
                        Text(chip.title)
                    }
                    .annotationTitles(.hidden)
                }

                if let pickedCoordinate {
                    Annotation(coordinate: pickedCoordinate) {
                        Image(uiImage: CityChipArtwork.pickedMarker)
                    } label: {
                        Text("Gewählter Punkt")
                    }
                    .annotationTitles(.hidden)
                }

                if showsUserLocation {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard(
                elevation: .flat,
                emphasis: .muted,
                pointsOfInterest: .excludingAll,
                showsTraffic: false
            ))
            .onTapGesture { point in
                guard let coordinate = proxy.convert(point, from: .local) else { return }
                onPick(coordinate)
            }
        }
    }
}

// MARK: - Chip artwork

@MainActor
private enum CityChipArtwork {
    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 64
        return cache
    }()
    static let pickedMarker = CityMarkerImage.make()

    static func image(for chip: CityMapChip) -> UIImage {
        let identity = [chip.emoji ?? "", chip.title]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        let temperatureKey = chip.temperature.map { String(Int($0.rounded())) } ?? "-"
        let key = "\(identity)|\(chip.iconAsset ?? "")|\(temperatureKey)" as NSString
        if let cached = cache.object(forKey: key) { return cached }

        let image: UIImage
        if let temperature = chip.temperature, let iconAsset = chip.iconAsset {
            image = MapChip.labeled(
                MapChip.conditions(
                    iconAsset: iconAsset,
                    temperatureText: "\(Int(temperature.rounded()))°"
                ),
                label: identity,
                balancedAnchor: true
            )
        } else {
            image = MapChip.labeled(
                MapChip.pin(emoji: chip.emoji),
                label: chip.title,
                balancedAnchor: true
            )
        }
        cache.setObject(image, forKey: key)
        return image
    }
}
