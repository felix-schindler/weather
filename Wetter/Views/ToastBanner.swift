//
//  ToastBanner.swift
//  Wetter
//

import SwiftUI

struct ToastBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.primary)
            .lineLimit(1)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .glassEffect(.regular, in: Capsule())
            .accessibilityElement()
            .accessibilityLabel(Text(message))
    }
}
