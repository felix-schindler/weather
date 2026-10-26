import SwiftUI

struct EnsembleView: View {
	let initialDate: Date

	@Environment(Location.self) private var location
	@State private var state = EnsembleState()
	@State private var expandedLens: EnsembleLens? = .high

	var body: some View {
		EnsembleContent(state: state, expandedLens: $expandedLens)
			.navigationTitle("Ensemble")
			.navigationBarTitleDisplayMode(.inline)
			.task(id: state.model) {
				await state.load(at: location.coordinates, anchor: initialDate)
			}
			.accessibilityIdentifier("ensemble.detail")
	}
}

private struct EnsembleModelPicker: View {
	let state: EnsembleState

	var body: some View {
		Menu {
			ForEach(DailyEnsembleModel.modelsByProvider, id: \.provider) { group in
				Section(group.provider.rawValue) {
					ForEach(group.models) { model in
						Toggle(isOn: Binding(get: { state.model == model }, set: { _ in state.model = model })) {
							Text(verbatim: model.displayName)
							Text(model.menuSubtitle)
						}
					}
				}
			}
		} label: {
			HStack(spacing: 4) {
				Text(verbatim: state.model.displayName)
				Image(systemName: "chevron.up.chevron.down")
					.imageScale(.small)
			}
			.font(.footnote.weight(.semibold))
			.foregroundStyle(.primary)
			.padding(.horizontal, 10)
			.padding(.vertical, 5)
			.glassEffect(.regular.interactive(), in: Capsule())
		}
		.accessibilityLabel(Text("Wettermodell"))
		.accessibilityValue(Text(verbatim: state.model.displayName))
	}
}

private struct EnsembleContent: View {
	let state: EnsembleState
	@Binding var expandedLens: EnsembleLens?

	var body: some View {
		Group {
			if state.days.isEmpty {
				if state.isLoading {
					ProgressView()
				} else {
					ContentUnavailableView {
						Label("Keine Ensemble-Daten", systemImage: "chart.line.downtrend.xyaxis")
					} description: {
						Text("Außerhalb der Modellabdeckung")
					} actions: {
						EnsembleModelPicker(state: state)
					}
				}
			} else {
				List {
					Section {
						VStack(alignment: .leading, spacing: 12) {
							DetailDeckCaption(eyebrow: state.eyebrowLabel, title: state.titleLabel, footnote: state.footnote)
							EnsembleModelPicker(state: state)
						}
					}

					Section {
						EnsembleDeck(state: state, expandedLens: $expandedLens)
					}

					Section {
						EnsembleRail(state: state)
					}
				}
				.listStyle(.insetGrouped)
			}
		}
		.sensoryFeedback(.selection, trigger: state.selectedIndex)
	}
}

private struct EnsembleDeck: View {
	let state: EnsembleState
	@Binding var expandedLens: EnsembleLens?

	var body: some View {
		VStack(spacing: 0) {
			ForEach(EnsembleLens.allCases) { lens in
				let isExpanded = lens == expandedLens
				DetailDeckRow(
					title: lens.title,
					systemImage: lens.systemImage,
					tint: lens.color,
					value: state.rowValue(for: lens),
					isExpanded: isExpanded,
					toggle: {
						withAnimation(.snappy) {
							expandedLens = isExpanded ? nil : lens
						}
					}
				) {
					EnsembleChart(state: state, lens: lens)
				}
			}
		}
	}
}
