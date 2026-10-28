import SwiftUI

enum EnvironmentDetailSection: String, CaseIterable, Identifiable {
	case aqi
	case uv
	case pollen

	var id: String { rawValue }

	var title: LocalizedStringKey {
		switch self {
		case .aqi:
			"Luftqualität"
		case .uv:
			"UV-Index"
		case .pollen:
			"Pollen"
		}
	}
}

struct EnvironmentDetailSectionPicker: View {
	@Binding var selection: EnvironmentDetailSection

	var body: some View {
		Picker("Umweltdetails", selection: $selection) {
			ForEach(EnvironmentDetailSection.allCases) { section in
				Text(section.title).tag(section)
			}
		}
		.pickerStyle(.segmented)
		.padding(.horizontal)
		.padding(.vertical, 8)
	}
}
