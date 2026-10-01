//
//  ExerciseCategory.swift
//  Arista
//

import Foundation

/// Liste fermée des catégories d'exercice proposées dans l'application.
///
/// Au départ, la catégorie était saisie dans un champ texte libre. Ça posait deux problèmes :
/// on pouvait enregistrer une catégorie vide (ou « foot », « Foot », « football »…),
/// et la liste ne savait pas quelle icône afficher pour une catégorie qu'elle ne connaissait pas.
/// J'ai donc choisi de proposer un choix parmi une liste connue.
///
/// Je n'ai pas modifié le modèle CoreData pour autant : l'attribut `Exercise.category` reste un
/// `String`, et c'est la `rawValue` de cette enum qui y est enregistrée. Ça garde le schéma
/// conforme à l'énoncé, et une catégorie inconnue déjà présente en base reste affichable.
///
/// ⚠️ Les `rawValue` sont persistées : si j'en renomme une, les exercices déjà enregistrés
/// avec l'ancien nom ne seront plus reconnus (ils s'afficheront avec l'icône par défaut).
enum ExerciseCategory: String, CaseIterable, Identifiable {
    case football = "Football"
    case running = "Running"
    case swimming = "Natation"
    case walking = "Marche"
    case cycling = "Cyclisme"
    case fitness = "Fitness"
    case weightTraining = "Musculation"
    case yoga = "Yoga"

    /// `Identifiable` me permet d'utiliser directement l'enum dans un `ForEach` (pour le `Picker`).
    /// La `rawValue` est unique pour chaque cas, c'est donc un identifiant stable.
    var id: String { rawValue }

    /// Nom du symbole SF Symbols affiché à côté de l'exercice dans la liste.
    var symbolName: String {
        switch self {
        case .football: return "figure.soccer"
        case .running: return "figure.run"
        case .swimming: return "figure.pool.swim"
        case .walking: return "figure.walk"
        case .cycling: return "figure.outdoor.cycle"
        case .fitness: return "figure.mixed.cardio"
        case .weightTraining: return "dumbbell"
        case .yoga: return "figure.yoga"
        }
    }

    /// Symbole utilisé quand la catégorie enregistrée ne correspond à aucun cas connu
    /// (donnée ancienne ou saisie avant l'ajout de cette liste).
    static let unknownSymbolName = "questionmark.circle"

    /// Retrouve le symbole à afficher à partir de la valeur brute stockée dans CoreData.
    ///
    /// Je passe par ici plutôt que de faire `ExerciseCategory(rawValue:)` dans la vue,
    /// pour que la vue n'ait pas à gérer elle-même le cas de la catégorie inconnue.
    static func symbolName(for storedCategory: String?) -> String {
        guard let storedCategory, let category = ExerciseCategory(rawValue: storedCategory) else {
            return unknownSymbolName
        }
        return category.symbolName
    }
}
