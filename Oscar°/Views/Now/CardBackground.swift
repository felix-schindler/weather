//
//  CardBackground.swift
//  Oscar°
//

import SwiftUI

extension EnvironmentValues {
    @Entry var cardBackgroundStyle = AnyShapeStyle(.thinMaterial)
}

private struct CardBackgroundModifier: ViewModifier {
    @Environment(\.cardBackgroundStyle) private var style

    func body(content: Content) -> some View {
        content.background(style)
    }
}

private struct CardShapeBackgroundModifier<S: Shape>: ViewModifier {
    @Environment(\.cardBackgroundStyle) private var style
    let shape: S

    func body(content: Content) -> some View {
        content.background(style, in: shape)
    }
}

private struct CardBorderModifier<S: InsettableShape>: ViewModifier {
    let shape: S

    func body(content: Content) -> some View {
        content.overlay(shape.strokeBorder(Color.primary.opacity(0.15), lineWidth: 1))
    }
}

extension View {
    func cardBackground() -> some View {
        modifier(CardBackgroundModifier())
    }

    func cardBackground(in shape: some Shape) -> some View {
        modifier(CardShapeBackgroundModifier(shape: shape))
    }

    func cardBorder(_ shape: some InsettableShape) -> some View {
        modifier(CardBorderModifier(shape: shape))
    }

    func cardBorder() -> some View {
        cardBorder(RoundedRectangle(cornerRadius: 10))
    }
}
