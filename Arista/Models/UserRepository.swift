//
//  UserRepository.swift
//  Arista
//

import Foundation
import CoreData

/// Accès en lecture aux données de l'utilisateur.
///
/// Le MVP ne gère qu'un seul utilisateur, créé au premier lancement par `DefaultData` :
/// je n'expose donc ni création, ni modification, ni suppression ici.
///
/// Pourquoi une couche « repository » plutôt qu'un `@FetchRequest` dans la vue ?
/// Pour respecter MVVM : la vue affiche, le ViewModel prépare les données, et seul le
/// repository sait parler à CoreData. Si un jour on changeait de système de stockage,
/// seuls les repositories seraient à réécrire.
struct UserRepository {
    /// Le contexte est injecté plutôt que codé en dur : c'est ce qui me permet, dans les
    /// tests, de travailler sur une base en mémoire vierge au lieu de la vraie base de l'app.
    let viewContext: NSManagedObjectContext

    /// La valeur par défaut pointe sur le contexte de l'application, pour que l'appel
    /// reste simple en usage normal : `UserRepository()`.
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Retourne l'utilisateur courant, ou `nil` si la base n'en contient aucun.
    ///
    /// `fetchLimit = 1` : il n'y a qu'un utilisateur, inutile d'en charger plus.
    /// Je ne gère pas l'erreur du `fetch` ici (d'où le `throws`) : un repository ne sait
    /// pas afficher une alerte, c'est au ViewModel de décider quoi montrer.
    func getUser() throws -> User? {
        let request = User.fetchRequest()
        request.fetchLimit = 1
        return try viewContext.fetch(request).first
    }
}
