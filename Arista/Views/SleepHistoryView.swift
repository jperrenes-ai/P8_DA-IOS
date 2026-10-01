//
//  SleepHistoryView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

/// Écran « Sommeil » : l'historique des nuits, en lecture seule.
struct SleepHistoryView: View {
    @State private var viewModel: SleepHistoryViewModel

    init(viewModel: SleepHistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // Dans le PoC, cet écran n'était dans aucune barre de navigation : le
        // `.navigationTitle` était donc ignoré et le titre ne s'affichait pas.
        NavigationStack {
            List(viewModel.sleepSessions) { session in
                SleepRow(
                    startDate: session.startDate,
                    duration: session.duration,
                    quality: Int(session.quality)
                )
            }
            .overlay {
                if viewModel.sleepSessions.isEmpty {
                    ContentUnavailableView(
                        "Aucune nuit enregistrée",
                        systemImage: "moon.zzz",
                        description: Text("Votre historique de sommeil apparaîtra ici.")
                    )
                }
            }
            .navigationTitle("Sommeil")
        }
        .errorAlert(message: $viewModel.errorMessage)
    }
}

/// Une ligne de l'historique : la qualité à gauche (comme l'icône dans la liste des exercices),
/// puis la date et la durée.
struct SleepRow: View {
    let startDate: Date?
    let duration: Int64
    let quality: Int

    var body: some View {
        HStack(spacing: 12) {
            QualityIndicator(quality: quality)

            VStack(alignment: .leading, spacing: 2) {
                if let startDate {
                    Text(startDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                }
                // « 7 h et 50 min » au lieu de l'ancien « 7 heures » arrondi (voir `formattedDuration`).
                Text("Durée : \(formattedDuration(minutes: duration))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SleepHistoryView(viewModel: SleepHistoryViewModel(context: PersistenceController.preview.container.viewContext))
}
