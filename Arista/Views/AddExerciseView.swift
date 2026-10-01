//
//  AddExerciseView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

/// Formulaire d'ajout d'un exercice, présenté en « sheet » depuis la liste.
struct AddExerciseView: View {
    /// `dismiss` remplace l'ancien `presentationMode`, déprécié : c'est l'action qui ferme la sheet.
    @Environment(\.dismiss) private var dismiss
    /// Le ViewModel est conservé par `@State`. C'est important ici : avec l'ancien
    /// `@ObservedObject`, si la liste derrière se redessinait pendant la saisie, un nouveau
    /// ViewModel pouvait être créé et le formulaire se vider.
    @State private var viewModel: AddExerciseViewModel

    init(viewModel: AddExerciseViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Activité") {
                    // Une liste de choix à la place du champ texte libre : impossible de saisir
                    // une catégorie vide ou mal orthographiée, et chaque choix a son icône.
                    Picker("Catégorie", selection: $viewModel.category) {
                        // Option « vide » pour obliger un choix explicite (la validation la refuse).
                        Text("Choisir…").tag("")
                        ForEach(ExerciseCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.symbolName)
                                .tag(category.rawValue)
                        }
                    }

                    // `in: ...Date()` empêche de choisir une date future directement dans le
                    // calendrier. La règle existe aussi dans `ExerciseValidator`, par sécurité.
                    DatePicker("Début", selection: $viewModel.startTime, in: ...Date())
                }

                Section {
                    // Des `Stepper` plutôt que des champs texte : la valeur reste toujours un
                    // nombre dans les bornes autorisées, et pas besoin de clavier.
                    Stepper(
                        value: $viewModel.duration,
                        in: 5...ExerciseValidator.durationRange.upperBound,
                        step: 5
                    ) {
                        LabeledContent("Durée", value: formattedDuration(minutes: Int64(viewModel.duration)))
                    }

                    Stepper(value: $viewModel.intensity, in: ExerciseValidator.intensityRange) {
                        LabeledContent("Intensité") {
                            IntensityIndicator(intensity: viewModel.intensity)
                        }
                    }
                } header: {
                    Text("Effort")
                } footer: {
                    // Le message de validation s'affiche en temps réel sous le formulaire,
                    // tant que la saisie n'est pas correcte.
                    if let message = viewModel.validationError?.errorDescription {
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Nouvel exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Disposition standard d'iOS pour une sheet : « Annuler » à gauche,
                // l'action principale à droite.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        // La sheet ne se ferme que si l'enregistrement a réussi ; sinon
                        // `errorMessage` est renseigné et l'alerte s'affiche.
                        if viewModel.addExercise() {
                            dismiss()
                        }
                    }
                    // Grisé tant que la saisie est invalide.
                    .disabled(!viewModel.isValid)
                }
            }
            .errorAlert(message: $viewModel.errorMessage)
        }
    }
}

#Preview {
    AddExerciseView(viewModel: AddExerciseViewModel(context: PersistenceController.preview.container.viewContext))
}
