//
//  UserRepository.swift
//  Arista
//

import Foundation
import CoreData

/// Accès en lecture aux données de l'utilisateur.
///
/// Le MVP ne gère qu'un seul utilisateur : ni création, ni modification, ni suppression
/// ne sont exposées ici. Le contexte est injecté afin que les tests puissent travailler
/// sur une base en mémoire plutôt que sur le store de l'application.
struct UserRepository {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Retourne l'utilisateur courant, ou `nil` si la base n'en contient aucun.
    ///
    /// L'erreur remontée par le `fetch` n'est pas traitée ici : c'est au ViewModel
    /// de décider comment la présenter.
    func getUser() throws -> User? {
        let request = User.fetchRequest()
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }
}
