//
//  AristaApp.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

/// Point d'entrée de l'application : une barre d'onglets avec les trois écrans du MVP.
@main
struct AristaApp: App {
    /// Le contrôleur CoreData de l'application (base enregistrée sur l'appareil).
    /// C'est en le créant que `DefaultData` remplit la base au premier lancement.
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                // Chaque écran reçoit son ViewModel, auquel on donne le contexte CoreData.
                // C'est l'injection de dépendances qui rend le tout testable : les tests font
                // la même chose, mais avec le contexte d'une base en mémoire.
                //
                // J'ai retiré les `.environment(\.managedObjectContext, ...)` du PoC : ils ne
                // servent qu'aux `@FetchRequest` utilisés directement dans les vues, ce qu'on
                // ne fait pas ici pour respecter MVVM (tout passe par les ViewModels).
                UserDataView(viewModel: UserDataViewModel(context: persistenceController.container.viewContext))
                    .tabItem {
                        Label("Utilisateur", systemImage: "person")
                    }

                ExerciseListView(viewModel: ExerciseListViewModel(context: persistenceController.container.viewContext))
                    .tabItem {
                        Label("Exercices", systemImage: "flame")
                    }

                SleepHistoryView(viewModel: SleepHistoryViewModel(context: persistenceController.container.viewContext))
                    .tabItem {
                        Label("Sommeil", systemImage: "moon")
                    }
            }
        }
    }
}
