//
//  SleepRepository.swift
//  Arista
//

import Foundation
import CoreData

/// Accès en lecture aux sessions de sommeil.
///
/// Les sessions sont préremplies à la création de la base (voir `DefaultData`) : le MVP
/// ne permet ni d'en ajouter, ni d'en modifier, ni d'en supprimer. Je n'expose donc
/// qu'une méthode de lecture.
struct SleepRepository {
    /// Contexte injecté, pour la même raison que dans `UserRepository` : pouvoir utiliser
    /// une base en mémoire dans les tests.
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Retourne toutes les sessions de sommeil, de la plus récente à la plus ancienne.
    ///
    /// Pas de `fetchLimit`, car on veut tout l'historique. Le tri décroissant sur `startDate`
    /// (`ascending: false`) affiche la nuit la plus récente en haut de la liste.
    func getSleepSessions() throws -> [Sleep] {
        let request = Sleep.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Sleep.startDate, ascending: false)]
        return try viewContext.fetch(request)
    }
}
