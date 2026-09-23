//
//  ExerciseType.swift
//  Arista
//

import Foundation

/// Types d'exercice supportés, correspondant à l'énumération `TypeExercice` du diagramme de classes.
/// La valeur brute est celle persistée dans l'attribut `ExerciseEntity.type` : ne jamais la modifier
/// sans migration, sous peine de rendre illisibles les exercices déjà enregistrés.
enum ExerciseType: String, CaseIterable, Identifiable {
    case cycling = "Vélo"
    case swimming = "Natation"
    case running = "Course"
    case weightTraining = "Musculation"
    case yoga = "Yoga"

    var id: String { rawValue }

    /// Libellé destiné à l'affichage.
    var displayName: String { rawValue }
}
