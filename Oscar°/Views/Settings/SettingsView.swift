//
//  SettingsView.swift
//  Oscar°
//
//  Created by Philipp Bolte on 28.08.21.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.scenePhase) private var scenePhase
  @Bindable private var settingsService = SettingService.shared
  @State private var showsMemory = false

  var body: some View {
    NavigationStack {
      List {
        Section("Wetter") {
          NavigationLink {
            NotificationSettingsView()
          } label: {
            Label("Benachrichtigungen", systemImage: "bell.badge.fill")
              .labelStyle(.settingsIcon(.red))
          }
          .accessibilityIdentifier("settings.alerts")

          NavigationLink {
            ForecastSettingsView()
          } label: {
            LabeledContent {
              if settingsService.forecastModelPreference != .bestMatch {
                Text(settingsService.forecastModelPreference.name)
              }
            } label: {
              Label("Vorhersage", systemImage: "calendar")
                .labelStyle(.settingsIcon(.teal))
            }
          }
          .accessibilityIdentifier("settings.forecast")

          NavigationLink {
            UnitSettings()
          } label: {
            Label("Einheiten", systemImage: "thermometer.medium")
              .labelStyle(.settingsIcon(.orange))
          }
        }

        Section("Darstellung") {
          NavigationLink {
            NowLayoutSettingsView()
          } label: {
            Label("Ansicht anpassen", systemImage: "rectangle.stack")
              .labelStyle(.settingsIcon(.pink))
          }
          .accessibilityIdentifier("settings.layout")

          Toggle(isOn: $settingsService.classicTheme) {
            classicThemeLabel
          }
        }

        Section("Allgemein") {
          NavigationLink {
            PermissionSettingsView()
          } label: {
            Label("Berechtigungen", systemImage: "lock.shield.fill")
              .labelStyle(.settingsIcon(.green))
          }

          NavigationLink {
            StatsView()
          } label: {
            Label("Statistik", systemImage: "chart.bar.fill")
              .labelStyle(.settingsIcon(.indigo))
          }

          Button {
            dismiss()
            OnboardingCoordinator.shared.replay()
          } label: {
            Label("Einführung erneut ansehen", systemImage: "sparkles")
              .labelStyle(.settingsIcon(.indigo))
          }
        }

        Section {
          SettingsExternalLink(destination: URL(string: "https://oscars.love/privacy")!) {
            Label("Datenschutz", systemImage: "hand.raised.fill")
              .labelStyle(.settingsIcon(.blue))
          }

          SettingsExternalLink(destination: URL(string: "https://oscars.love/impressum")!) {
            Label("Impressum", systemImage: "figure.wave")
              .labelStyle(.settingsIcon(.gray))
          }

          NavigationLink {
            DataSourcesView()
          } label: {
            Label("Datenquellen & Lizenzen", systemImage: "books.vertical.fill")
              .labelStyle(.settingsIcon(.purple))
          }
        } header: {
          Text("Über")
        } footer: {
          aboutFooter
        }
      }
      .navigationTitle("Einstellungen")
      .toolbarTitleDisplayMode(.inline)
      .accessibilityIdentifier("settings.sheet")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(role: .close) {
            dismiss()
          }
        }
      }
      .navigationDestination(isPresented: $showsMemory) {
        MemoryView()
      }
      .task {
        await NotificationSettingsManager.shared.reloadNotificationStatus()
      }
      .onChange(of: scenePhase) { _, newPhase in
        guard newPhase == .active else { return }
        Task { await NotificationSettingsManager.shared.reloadNotificationStatus() }
      }
    }
  }

  private var classicThemeLabel: some View {
    Label("Klassisch", systemImage: "clock.arrow.circlepath")
      .labelStyle(.settingsIcon(.gray))
  }

  private var aboutFooter: some View {
    VStack(spacing: 2) {
      Text(verbatim: "Oscar° \(appVersion) (\(appBuild))")
      Text("by Philipp Bolte")
    }
    .frame(maxWidth: .infinity)
    .multilineTextAlignment(.center)
    .padding(.top, 12)
    .contentShape(Rectangle())
    .onTapGesture {
      showsMemory = true
    }
  }

  private var appVersion: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
  }

  private var appBuild: String {
    Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
  }
}

#Preview {
  SettingsView()
}
