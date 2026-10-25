import SwiftUI

protocol DetailSection: CaseIterable, Hashable, Identifiable where AllCases: RandomAccessCollection {
    var title: LocalizedStringKey { get }
}

struct DetailSectionPicker<Section: DetailSection>: View {
    let label: LocalizedStringKey
    @Binding var selection: Section

    var body: some View {
        Picker(label, selection: $selection) {
            ForEach(Section.allCases) { section in
                Text(section.title).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
