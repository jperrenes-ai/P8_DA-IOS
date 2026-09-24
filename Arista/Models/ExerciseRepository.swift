//
//  ExerciseRepository.swift
//  Arista
//

import Foundation
import CoreData

/// Erreurs métier propres à la manipulation des exercices.
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
/// C'est la seule entité que l'utilisateur peut créer et supprimer depuis l'application.
struct ExerciseRepository {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Retourne tous les exercices, du plus récent au plus ancien.
    func getExercise() throws -> [Exercise] {
        let request = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Exercise.startDate, ascending: false)]
        return try viewContext.fetch(request)
    }

    /// Crée un exercice et le rattache à l'utilisateur courant.
    ///
    /// La relation vers l'utilisateur étant obligatoire dans le modèle, l'absence
    /// d'utilisateur est signalée explicitement plutôt que de laisser échouer la
    /// validation de CoreData avec une erreur difficile à interpréter.
    func addExercise(category: String, duration: Int, intensity: Int, startDate: Date) throws {
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
    func deleteExercise(_ exercise: Exercise) throws {
        viewContext.delete(exercise)
        try viewContext.save()
    }
}
