//
//  AddExerciseViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class AddExerciseViewModel: ObservableObject {
    @Published var category: String = ""
    @Published var startTime: Date = Date()
    @Published var duration: Int = 0
    @Published var intensity: Int = 0
    /// Message à afficher à l'utilisateur si l'enregistrement échoue, `nil` sinon.
    @Published var errorMessage: String?

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    /// Enregistre l'exercice saisi. Retourne `true` si la vue peut se fermer.
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
            // Les erreurs métier (ex. aucun utilisateur) portent leur propre message.
            errorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Impossible d'enregistrer l'exercice."
            return false
        }
    }
}
