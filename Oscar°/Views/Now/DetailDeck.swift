import SwiftUI

struct DetailDeckCaption: View {
    let eyebrow: String
    let title: String
    var footnote: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: eyebrow)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(.snappy, value: eyebrow)

            Text(verbatim: title)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            if let footnote {
                Text(verbatim: footnote)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

struct DetailDeckRow<Chart: View>: View {
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    let value: String
    let isExpanded: Bool
    let toggle: () -> Void
    @ViewBuilder let chart: Chart

    var body: some View {
        DisclosureGroup(isExpanded: expansion) {
            chart
                .frame(height: 176)
        } label: {
            header
        }
    }

    private var expansion: Binding<Bool> {
        Binding(
            get: { isExpanded },
            set: { expanded in
                guard expanded != isExpanded else { return }
                toggle()
            }
        )
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(tint)
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(verbatim: value)
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(Text(verbatim: value))
        .accessibilityHint(isExpanded ? Text("Klappt das Diagramm ein") : Text("Zeigt das Diagramm"))
    }
}
