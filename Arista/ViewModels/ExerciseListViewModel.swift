//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation

import CoreData

class ExerciseListViewModel: ObservableObject {
    @Published var exercises = [Exercise]()
    /// Message à afficher à l'utilisateur si une opération échoue, `nil` sinon.
    @Published var errorMessage: String?

    var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExercises()
    }

    /// Rejoue la requête, par exemple après l'ajout d'un exercice depuis une autre vue.
    func reload() {
        fetchExercises()
    }

    /// Supprime les exercices aux positions données, telles que fournies par `onDelete`.
    func deleteExercises(at offsets: IndexSet) {
        let repository = ExerciseRepository(viewContext: viewContext)
        do {
            for index in offsets {
                try repository.deleteExercise(exercises[index])
            }
        } catch {
            errorMessage = "Impossible de supprimer l'exercice."
        }
        fetchExercises()
    }

    private func fetchExercises() {
        do {
            exercises = try ExerciseRepository(viewContext: viewContext).getExercise()
        } catch {
            errorMessage = "Impossible de charger les exercices."
        }
    }
}
