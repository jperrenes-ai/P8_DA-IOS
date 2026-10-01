//
//  ExerciseRepository.swift
//  Arista
//

import Foundation
import CoreData

/// Erreurs métier propres à la manipulation des exercices.
///
/// Les erreurs de *saisie* (catégorie, durée…) sont dans `ExerciseValidationError`.
/// Ici, il s'agit d'un problème d'état de la base, indépendant de ce que l'utilisateur a tapé.
enum ExerciseRepositoryError: LocalizedError {
    /// Aucun utilisateur n'existe en base : impossible de rattacher l'exercice.
    case noUserFound

    var errorDescription: String? {
        switch self {
        case .noUserFound:
            return "Aucun utilisateur n'a été trouvé. Impossible d'enregistrer l'exercice."
        }
    }
}

/// Accès en lecture et en écriture aux exercices.
///
/// C'est la seule entité que l'utilisateur peut créer et supprimer depuis l'application
/// (l'utilisateur et le sommeil sont en lecture seule dans le MVP).
///
/// Comme pour les autres repositories, j'en ai fait une `struct` qui reçoit son
/// `NSManagedObjectContext` : en temps normal c'est le contexte de l'application,
/// et dans les tests je lui passe le contexte d'une base en mémoire.
struct ExerciseRepository {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Retourne tous les exercices, du plus récent au plus ancien.
    ///
    /// Pas de `fetchLimit` : on veut la liste complète. J'utilise la version `keyPath` du
    /// `NSSortDescriptor` plutôt qu'une chaîne `"startDate"` : si je me trompe dans le nom
    /// de l'attribut, c'est le compilateur qui me le signale, pas un crash à l'exécution.
    func getExercise() throws -> [Exercise] {
        let request = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.startDate, ascending: false)]
        return try viewContext.fetch(request)
    }

    /// Valide puis crée un exercice, rattaché à l'utilisateur courant.
    ///
    /// L'ordre des vérifications est volontaire :
    /// 1. d'abord la validation de la saisie (`ExerciseValidator`) — si la donnée est
    ///    mauvaise, inutile d'aller plus loin, et rien n'est créé dans le contexte ;
    /// 2. ensuite la présence d'un utilisateur. La relation `user` est obligatoire dans
    ///    le modèle : sans ce `guard`, CoreData refuserait la sauvegarde avec une erreur de
    ///    validation peu parlante (c'est le « 1er problème potentiel » décrit dans l'énoncé).
    ///
    /// Les `Int` reçus du formulaire sont convertis en `Int64`, le type que CoreData génère
    /// pour les attributs `Integer 64`.
    func addExercise(category: String, duration: Int, intensity: Int, startDate: Date) throws {
        try ExerciseValidator.validate(
            category: category,
            duration: duration,
            intensity: intensity,
            startDate: startDate
        )

        guard let user = try UserRepository(viewContext: viewContext).getUser() else {
            throw ExerciseRepositoryError.noUserFound
        }

        let newExercise = Exercise(context: viewContext)
        newExercise.category = category
        newExercise.duration = Int64(duration)
        newExercise.intensity = Int64(intensity)
        newExercise.startDate = startDate
        newExercise.user = user

        try viewContext.save()
    }

    /// Supprime un exercice de la base.
    ///
    /// Cette méthode n'est pas dans le corrigé de l'énoncé, mais le mail de Laxmi demande
    /// explicitement que la suppression soit possible depuis la liste.
    func deleteExercise(_ exercise: Exercise) throws {
        viewContext.delete(exercise)
        try viewContext.save()
    }
}
