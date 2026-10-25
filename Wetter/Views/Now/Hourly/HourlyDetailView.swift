import SwiftUI

struct HourlyDetailView: View {
	var initialTarget: Date? = nil

	@Environment(Weather.self) private var weather: Weather
	@Environment(\.dismiss) private var dismiss

	@State private var model = HourlyTimelineModel()
	@State private var ensembleDate: Date?

	var body: some View {
		NavigationStack {
			Group {
				if model.hasData {
					HourlyContent(model: model)
				} else {
					ContentUnavailableView(
						"Keine stündlichen Daten",
						systemImage: "clock.badge.questionmark",
						description: Text("Für diesen Standort liegen aktuell keine stündlichen Details vor.")
					)
				}
			}
			.navigationTitle("Stündlich")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Ensemble") {
						ensembleDate = Date(timeIntervalSince1970: model.scrubTime)
					}
					.accessibilityHint(Text("Zeigt, wie sicher die Vorhersage der nächsten Wochen ist"))
					.accessibilityIdentifier("hourly.ensemble")
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button(role: .close, action: finish)
				}
			}
			.navigationDestination(item: $ensembleDate) { date in
				EnsembleView(initialDate: date)
					.toolbar {
						ToolbarItem(placement: .topBarTrailing) {
							Button(role: .close, action: finish)
						}
					}
			}
			.onAppear {
				model.update(from: weather)
				if let initialTarget {
					model.scrub(to: initialTarget.timeIntervalSince1970)
				}
			}
			.onChange(of: weather.lastUpdated) { _, _ in
				model.update(from: weather)
			}
		}
	}

	private func finish() {
		dismiss()
	}
}

private struct HourlyContent: View {
	let model: HourlyTimelineModel

	@State private var expandedLens: HourlyLens? = .overview
	@State private var dragStartTime: Double?

	private static let secondsPerPoint: Double = 240

	var body: some View {
		List {
			Section {
				HourlyCaption(model: model)
			}

			Section {
				HourlyDeck(model: model, expandedLens: $expandedLens)
			}

			Section {
				HourlyTimelineMinimap(model: model)
			}
		}
		.listStyle(.insetGrouped)
		.simultaneousGesture(skyDrag)
		.accessibilityIdentifier("hourly.detail")
	}

	private var skyDrag: some Gesture {
		DragGesture(minimumDistance: 12)
			.onChanged { value in
				if dragStartTime == nil {
					guard abs(value.translation.width) > abs(value.translation.height) else { return }
					dragStartTime = model.scrubTime
				}
				guard let dragStartTime else { return }
				model.scrub(to: dragStartTime - value.translation.width * Self.secondsPerPoint)
			}
			.onEnded { _ in
				dragStartTime = nil
			}
	}
}

private struct HourlyCaption: View {
	let model: HourlyTimelineModel

	var body: some View {
		DetailDeckCaption(eyebrow: model.eyebrowLabel, title: model.titleLabel)
	}
}

private struct HourlyDeck: View {
	let model: HourlyTimelineModel
	@Binding var expandedLens: HourlyLens?

	var body: some View {
		VStack(spacing: 0) {
			ForEach(HourlyLens.allCases) { lens in
				let isExpanded = lens == expandedLens
				DetailDeckRow(
					title: lens.title,
					systemImage: lens.systemImage,
					tint: model.layout(for: lens).primaryColor,
					value: model.rowValue(for: lens) ?? "--",
					isExpanded: isExpanded,
					toggle: {
						withAnimation(.snappy) {
							expandedLens = isExpanded ? nil : lens
						}
					}
				) {
					HourlyTimelineStrip(model: model, lens: lens)
				}
			}
		}
	}
}

#Preview {
	HourlyDetailView()
		.environment(Weather.mock)
		.environment(Location())
		.environment(NowPresentationCoordinator())
}
