//
//  LocationCard.swift
//  Oscar°
//
//  A saved place as a standard list row: name, personalization mark,
//  current conditions, and temperature.
//

import SwiftUI

struct LocationCard: View {
    let title: String
    var detail: String?
    var mark: PlacePersonalization.Mark = .plain
    var temperature: Double?
    var isSelected = false
    var isDefault = false

    var body: some View {
        HStack(spacing: 12) {
            if hasBadge {
                badgeContent
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(title)
                        .lineLimit(1)
                    if isDefault {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                            .accessibilityHidden(true)
                    }
                }
                if let detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text(temperature.map { "\(Int($0.rounded()))°" } ?? "--°")
                .font(.title3)
                .monospacedDigit()
                .foregroundStyle(temperature == nil ? .secondary : .primary)
                .contentTransition(.numericText())
                .animation(.default, value: temperature)

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
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
            Text(emoji).font(.title2)
        case .locationGlyph:
            Image(systemName: "location.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
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

#Preview {
    List {
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
    .environment(Weather.mock)
}
