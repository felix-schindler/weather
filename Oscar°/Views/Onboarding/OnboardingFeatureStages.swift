//
//  OnboardingFeatureStages.swift
//  Oscar°
//

import SwiftUI

struct OnboardingFeatureStage: View {
    let page: OnboardingTourPage
    var radarGrids: Task<[[UInt8]], Never>?

    @Environment(\.onboardingLayout) private var layout
    @State private var weather = Weather.mock

    var body: some View {
        Group {
            switch page {
            case .forecast where layout.isPad:
                inset {
                    DailyView(expandsDays: true)
                        .environment(weather)
                        .environment(NowPresentationCoordinator())
                        .allowsHitTesting(false)
                }
            case .forecast: inset { ForecastStage() }
            case .map: inset { OnboardingMapStage(prebuiltGrids: radarGrids) }
            case .ensemble: inset { EnsembleStage() }
            case .more: OnboardingExtrasStage().padding(.horizontal, -80)
            }
        }
    }

    private func inset(@ViewBuilder _ content: () -> some View) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct ForecastStage: View {
    var body: some View {
        ViewThatFits(in: .vertical) {
            VStack(spacing: 12) {
                hourlyRow
                CollageDailyCard()
                logos
            }
            VStack(spacing: 12) {
                hourlyRow
                CollageDailyCard(dayCount: 3)
                logos
            }
            VStack(spacing: 12) {
                hourlyRow
                logos
            }
        }
        .accessibilityHidden(true)
    }

    private var hourlyRow: some View {
        ViewThatFits(in: .horizontal) {
            HourlyRow(count: 5)
            HourlyRow(count: 4)
            HourlyRow(count: 3)
        }
    }

    private var logos: some View {
        HStack(spacing: 22) {
            ProviderLogo(asset: "logo-dwd", height: 30)
            ProviderLogo(asset: "logo-ecmwf", height: 16)
            ProviderLogo(asset: "logo-noaa", height: 30)
        }
        .foregroundStyle(.primary)
        .padding(.top, 4)
    }
}

private struct HourlyRow: View {
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingSampleData.hourlyItems.prefix(count)) { item in
                HourlyForecastCard(item: item)
            }
        }
    }
}

private struct EnsembleStage: View {
    @State private var state = EnsembleState()
    @State private var expandedLens: EnsembleLens? = .high

    var body: some View {
        ViewThatFits(in: .vertical) {
            content(lenses: [.high, .precipitation, .sky], showsRail: true)
            content(lenses: [.high, .precipitation], showsRail: false)
            content(lenses: [.high], showsRail: false)
            content(lenses: [.high], showsRail: false, showsCaption: false)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 24))
        .onAppear {
            if state.days.isEmpty {
                state.stage(OnboardingSampleData.ensembleDays, selectedIndex: 1)
            }
        }
    }

    private func content(lenses: [EnsembleLens], showsRail: Bool, showsCaption: Bool = true) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if showsCaption {
                DetailDeckCaption(eyebrow: state.eyebrowLabel, title: state.titleLabel, footnote: state.footnote)
                    .padding(.horizontal, 6)
            }

            VStack(spacing: 0) {
                ForEach(lenses.enumerated(), id: \.element) { _, lens in
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

            if showsRail {
                EnsembleRail(state: state)
            }
        }
    }
}

#Preview {
    TabView {
        ForEach(OnboardingTourPage.allCases, id: \.self) { page in
            OnboardingFeatureStage(page: page)
                .frame(height: 420)
                .background(Color(uiColor: .systemBackground))
                .clipShape(.rect(cornerRadius: 28))
                .padding()
        }
    }
    .tabViewStyle(.page)
    .environment(Weather.mock)
}
