//
//  ExerciseValidator.swift
//  Arista
//

import Foundation

/// Les différentes raisons pour lesquelles un exercice peut être refusé.
///
/// Je les ai déclarées en `LocalizedError` pour que chaque cas porte directement son message :
/// le ViewModel n'a plus qu'à afficher `errorDescription`, sans avoir à connaître les règles.
/// `Equatable` me sert surtout dans les tests, pour vérifier quelle erreur précise est levée.
enum ExerciseValidationError: LocalizedError, Equatable {
    /// La catégorie est vide ou ne fait pas partie de `ExerciseCategory`.
    case invalidCategory
    /// La durée n'est pas comprise dans `ExerciseValidator.durationRange`.
    case invalidDuration
    /// L'intensité n'est pas comprise dans `ExerciseValidator.intensityRange`.
    case invalidIntensity
    /// La date de début est dans le futur : on enregistre un exercice déjà fait.
    case startDateInFuture

    var errorDescription: String? {
        switch self {
        case .invalidCategory:
            return "Choisissez une catégorie d'exercice."
        case .invalidDuration:
            return "La durée doit être comprise entre \(ExerciseValidator.durationRange.lowerBound) et \(ExerciseValidator.durationRange.upperBound) minutes."
        case .invalidIntensity:
            return "L'intensité doit être comprise entre \(ExerciseValidator.intensityRange.lowerBound) et \(ExerciseValidator.intensityRange.upperBound)."
        case .startDateInFuture:
            return "La date de début ne peut pas être dans le futur."
        }
    }
}

/// Règles de validation d'un exercice, regroupées à un seul endroit.
///
/// L'énoncé fait remarquer que « la validation des informations n'est faite ni dans la View
/// ni dans le Model ». J'ai donc placé les règles ici, dans la couche Model, et elles sont
/// utilisées à deux endroits :
/// - par `ExerciseRepository.addExercise`, qui refuse d'enregistrer une donnée invalide,
///   quel que soit l'appelant (c'est la vraie protection de la base) ;
/// - par `AddExerciseViewModel`, pour afficher le message dans le formulaire *avant* même
///   que l'utilisateur appuie sur « Ajouter ».
///
/// Comme les deux s'appuient sur la même fonction, les règles ne peuvent pas diverger.
enum ExerciseValidator {
    /// Une durée nulle n'a pas de sens, et je plafonne à 24 h (1440 min) pour bloquer
    /// les fautes de frappe du genre « 4500 » au lieu de « 45 ».
    static let durationRange = 1...1440

    /// L'intensité est notée de 0 à 10, comme indiqué dans le PoC d'origine.
    static let intensityRange = 0...10

    /// Vérifie un exercice et lève la première erreur rencontrée.
    ///
    /// - Parameter now: la date de référence pour « le futur ». Je l'ai mise en paramètre
    ///   (avec `Date()` par défaut) pour pouvoir tester le cas limite sans dépendre de l'horloge.
    static func validate(
        category: String,
        duration: Int,
        intensity: Int,
        startDate: Date,
        now: Date = Date()
    ) throws {
        guard ExerciseCategory(rawValue: category) != nil else {
            throw ExerciseValidationError.invalidCategory
        }
        guard durationRange.contains(duration) else {
            throw ExerciseValidationError.invalidDuration
        }
        guard intensityRange.contains(intensity) else {
            throw ExerciseValidationError.invalidIntensity
        }
        guard startDate <= now else {
            throw ExerciseValidationError.startDateInFuture
        }
    }
}
