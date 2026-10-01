//
//  ExerciseListViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import Observation

/// ViewModel de l'écran « Exercices » : il fournit la liste et gère la suppression.
///
/// L'ajout, lui, est géré par un autre ViewModel (`AddExerciseViewModel`), propre au formulaire.
@MainActor
@Observable
final class ExerciseListViewModel {
    /// Les exercices, du plus récent au plus ancien. Ce sont directement les entités CoreData
    /// `Exercise` (avant, c'était un tableau de `FakeExercise`).
    var exercises = [Exercise]()
    /// Message à afficher à l'utilisateur si une opération échoue, `nil` sinon.
    var errorMessage: String?

    /// Ce contexte n'est pas `private` : la vue en a besoin pour créer le ViewModel du
    /// formulaire d'ajout, afin que l'exercice soit enregistré dans la même base.
    @ObservationIgnored let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchExercises()
    }

    /// Rejoue la requête, par exemple après l'ajout d'un exercice depuis le formulaire.
    ///
    /// Sans ça, j'avais le problème décrit dans l'énoncé : le nouvel exercice n'apparaissait
    /// qu'au redémarrage de l'app, car la liste avait été chargée une seule fois, dans l'`init`.
    func reload() {
        fetchExercises()
    }

    /// Supprime les exercices aux positions données.
    ///
    /// La signature `(IndexSet)` correspond exactement à ce que fournit le modificateur
    /// `.onDelete` de SwiftUI : la vue peut donc écrire `.onDelete(perform: viewModel.deleteExercises)`.
    /// Je recharge la liste à la fin dans tous les cas, pour que l'affichage reflète
    /// toujours l'état réel de la base, même si la suppression a échoué.
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
