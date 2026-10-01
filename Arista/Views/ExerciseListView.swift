//
//  ExerciseListView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

/// Écran « Exercices » : la liste des exercices, avec ajout et suppression.
struct ExerciseListView: View {
    /// Voir `UserDataView` : la vue possède son ViewModel via `@State`.
    @State private var viewModel: ExerciseListViewModel
    /// Contrôle l'affichage du formulaire d'ajout (la « sheet »).
    @State private var showingAddExerciseView = false

    init(viewModel: ExerciseListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                // `ForEach` (plutôt que `List(viewModel.exercises)`) est nécessaire pour pouvoir
                // brancher `.onDelete`. Les objets CoreData sont `Identifiable` : leur identité
                // est stable, donc SwiftUI anime correctement l'ajout et la suppression des lignes.
                ForEach(viewModel.exercises) { exercise in
                    // Je passe à la ligne uniquement les valeurs qu'elle affiche, déjà « nettoyées »
                    // des optionnels de CoreData, plutôt que l'objet `Exercise` entier.
                    ExerciseRow(
                        category: exercise.category ?? "",
                        duration: exercise.duration,
                        intensity: Int(exercise.intensity),
                        startDate: exercise.startDate
                    )
                }
                // Glisser une ligne vers la gauche fait apparaître « Supprimer ».
                .onDelete(perform: viewModel.deleteExercises)
            }
            .overlay {
                // État vide : plutôt qu'une liste blanche, j'explique comment commencer.
                if viewModel.exercises.isEmpty {
                    ContentUnavailableView(
                        "Aucun exercice",
                        systemImage: "figure.run",
                        description: Text("Appuyez sur + pour enregistrer votre premier exercice.")
                    )
                }
            }
            .navigationTitle("Exercices")
            .toolbar {
                // `.toolbar` remplace `.navigationBarItems`, déprécié.
                ToolbarItem(placement: .primaryAction) {
                    Button("Ajouter un exercice", systemImage: "plus") {
                        showingAddExerciseView = true
                    }
                }
            }
            // `onDismiss` rejoue la requête quand le formulaire se ferme : c'est la correction
            // du bug de l'énoncé où le nouvel exercice n'apparaissait qu'au redémarrage.
            .sheet(isPresented: $showingAddExerciseView, onDismiss: viewModel.reload) {
                // Le formulaire reçoit le même contexte CoreData que la liste, pour que l'exercice
                // soit enregistré dans la même base.
                AddExerciseView(viewModel: AddExerciseViewModel(context: viewModel.viewContext))
            }
        }
        // Recharge aussi en revenant sur l'onglet, par sécurité.
        .onAppear(perform: viewModel.reload)
        .errorAlert(message: $viewModel.errorMessage)
    }
}

/// Une ligne de la liste des exercices.
///
/// Je l'ai sortie dans sa propre vue pour alléger `ExerciseListView` et pour corriger un défaut
/// d'alignement : les symboles n'ont pas tous la même largeur, donc le texte commençait plus ou
/// moins loin selon la catégorie. Le `frame(width:)` fixe sur l'icône règle ça.
struct ExerciseRow: View {
    let category: String
    let duration: Int64
    let intensity: Int
    let startDate: Date?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: ExerciseCategory.symbolName(for: category))
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                // Un exercice ancien peut avoir une catégorie vide (avant la validation) :
                // j'affiche un libellé plutôt qu'une ligne vide.
                Text(category.isEmpty ? "Sans catégorie" : category)
                    .font(.headline)
                Text(formattedDuration(minutes: duration))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let startDate {
                    Text(startDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            IntensityIndicator(intensity: intensity)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExerciseListView(viewModel: ExerciseListViewModel(context: PersistenceController.preview.container.viewContext))
}
