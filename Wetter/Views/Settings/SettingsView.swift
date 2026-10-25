//
//  SettingsView.swift
//  Wetter
//
//  Created by Philipp Bolte on 28.08.21.
//

import SwiftUI

struct SettingsView: View {
  var showsCloseButton = true
  @Environment(\.dismiss) private var dismiss
  @Environment(\.scenePhase) private var scenePhase
  @Bindable private var settingsService = SettingService.shared

  var body: some View {
    NavigationStack {
      List {
        Section("Wetter") {
          NavigationLink {
            NotificationSettingsView()
          } label: {
            Label("Mitteilungen", systemImage: "bell.badge.fill")
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
        }
      }
      .navigationTitle("Einstellungen")
      .toolbarTitleDisplayMode(.inline)
      .accessibilityIdentifier("settings.sheet")
      .toolbar {
        if showsCloseButton {
          ToolbarItem(placement: .topBarTrailing) {
            Button(role: .close) {
              dismiss()
            }
          }
        }
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
}

#Preview {
  SettingsView()
}
