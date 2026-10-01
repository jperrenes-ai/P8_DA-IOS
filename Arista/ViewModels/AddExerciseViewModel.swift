//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import Observation

/// ViewModel du formulaire d'ajout d'un exercice.
///
/// Il détient les valeurs saisies, dit à la vue si elles sont valides, et enregistre
/// l'exercice via le repository.
@MainActor
@Observable
final class AddExerciseViewModel {
    /// Catégorie choisie, stockée sous forme de `rawValue` de `ExerciseCategory`.
    /// Vide au départ : l'utilisateur doit faire un choix explicite.
    var category: String = ""
    /// Date et heure de début. Par défaut « maintenant », le cas le plus courant.
    var startTime: Date = Date()
    /// Durée en minutes. J'ai mis 30 par défaut plutôt que 0, qui serait refusé par la validation.
    var duration: Int = 30
    /// Intensité de 0 à 10. Valeur médiane par défaut.
    var intensity: Int = 5
    /// Message à afficher si l'enregistrement échoue, `nil` sinon.
    var errorMessage: String?

    // Dans le PoC d'origine, ces quatre propriétés étaient toutes des `String`, liées à des
    // `TextField`. Je les ai passées dans leur vrai type (`Date`, `Int`) : la conversion n'est
    // plus à faire, et une durée comme « abc » devient tout simplement impossible à saisir.

    @ObservationIgnored private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    /// L'erreur de validation de la saisie actuelle, ou `nil` si tout est correct.
    ///
    /// C'est une propriété calculée : elle est réévaluée à chaque changement d'un champ, ce qui
    /// permet à la vue d'afficher le message et de griser le bouton en temps réel.
    /// Les règles elles-mêmes sont dans `ExerciseValidator` (couche Model), pour qu'elles soient
    /// identiques ici et dans le repository.
    var validationError: ExerciseValidationError? {
        do {
            try ExerciseValidator.validate(
                category: category,
                duration: duration,
                intensity: intensity,
                startDate: startTime
            )
            return nil
        } catch {
            // `validate` ne lève que des `ExerciseValidationError`, mais le compilateur ne peut
            // pas le savoir (les `throws` de Swift 5 ne sont pas typés) : d'où le `as?`.
            return error as? ExerciseValidationError
        }
    }

    /// Vrai si la saisie peut être enregistrée. Sert à activer le bouton « Ajouter ».
    var isValid: Bool {
        validationError == nil
    }

    /// Enregistre l'exercice saisi. Retourne `true` si la vue peut se fermer.
    ///
    /// Je garde la signature `-> Bool` du PoC : c'est simple côté vue (« si ça a marché, je
    /// ferme »). En cas d'échec, le message est dans `errorMessage`.
    func addExercise() -> Bool {
        do {
            try ExerciseRepository(viewContext: viewContext).addExercise(
                category: category,
                duration: duration,
                intensity: intensity,
                startDate: startTime
            )
            return true
        } catch {
            // Les erreurs « métier » (saisie invalide, aucun utilisateur) sont des `LocalizedError`
            // qui portent leur propre message. Pour une erreur CoreData brute, dont le message
            // technique ne parlerait pas à l'utilisateur, j'affiche un message générique.
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Impossible d'enregistrer l'exercice."
            return false
        }
    }
}
