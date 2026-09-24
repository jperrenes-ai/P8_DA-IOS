//
//  SleepRepository.swift
//  Arista
//

import Foundation
import CoreData

/// Accès en lecture aux sessions de sommeil.
///
/// Les sessions sont préremplies à la création de la base : le MVP ne permet ni
/// d'en ajouter, ni d'en modifier, ni d'en supprimer.
struct SleepRepository {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Retourne toutes les sessions de sommeil, de la plus récente à la plus ancienne.
    func getSleepSessions() throws -> [Sleep] {
        let request = Sleep.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sleep.startDate, ascending: false)]
        return try viewContext.fetch(request)
    }
}
