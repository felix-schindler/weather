//
//  LocationCard.swift
//  Oscar°
//
//  A saved location as a card: a static miniature of the weather simulation
//  showing the place's current sky, with name, label emoji, and temperature.
//

import SwiftUI

struct LocationCard: View {
    let title: String
    var detail: String?
    var mark: PlacePersonalization.Mark = .plain
    var temperature: Double?
    var isSelected = false
    var isDefault = false

    @ScaledMetric(relativeTo: .headline) private var cardHeight: CGFloat = 102
    @ScaledMetric(relativeTo: .title) private var temperatureFontSize: CGFloat = 36

    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                if hasBadge {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.16))
                            .overlay { Circle().strokeBorder(.white.opacity(0.22), lineWidth: 1) }
                        badgeContent
                    }
                    .frame(width: 44, height: 44)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        if isDefault {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow.opacity(0.95))
                                .accessibilityHidden(true)
                        }
                    }
                    if let detail {
                        Text(detail)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                Text(temperature.map { "\(Int($0.rounded()))°" } ?? "--°")
                    .font(.system(size: temperatureFontSize, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(temperature == nil ? 0.4 : 1))
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.5), value: temperature)
            }
            .padding(.horizontal, 16)
            .shadow(color: .black.opacity(0.35), radius: 3, y: 1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    .white.opacity(isSelected ? 0.75 : 0.12),
                    lineWidth: isSelected ? 1.75 : 1
                )
        )
        .overlay(alignment: .topTrailing) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.subheadline)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.black.opacity(0.65), .white)
                    .padding(9)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityHidden(true)
            }
        }
        .animation(.spring(duration: 0.35), value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
        .accessibilityValue(isSelected ? Text("Ausgewählt") : Text(""))
    }

    private var hasBadge: Bool {
        mark != .plain
    }

    @ViewBuilder
    private var badgeContent: some View {
        switch mark {
        case .emoji(let emoji):
            Text(emoji).font(.system(size: 24))
        case .locationGlyph:
            Image(systemName: "location.fill")
                .font(.body)
                .foregroundStyle(.white)
        case .plain:
            EmptyView()
        }
    }

    private var accessibilityText: Text {
        var parts = [title]
        if let detail { parts.append(detail) }
        if let temperature { parts.append("\(Int(temperature.rounded())) Grad") }
        if isDefault { parts.append(String(localized: "Standardort")) }
        return Text(parts.joined(separator: ", "))
    }
}

struct LocationCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 12) {
        LocationCard(
            title: "Zuhause",
            detail: "Leipzig · Klar",
            mark: .emoji("🏠"),
            temperature: 21.4,
            isSelected: true,
            isDefault: true
        )
        LocationCard(
            title: "Mein Standort",
            detail: "Gewitter",
            mark: .locationGlyph,
            temperature: 17.2
        )
        LocationCard(
            title: "Oma",
            detail: "Hessen",
            mark: .emoji("👵"),
            temperature: nil
        )
    }
    .padding()
    .background(Color.black)
    .environment(Weather.mock)
}
