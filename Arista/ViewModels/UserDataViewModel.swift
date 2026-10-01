//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import Observation

/// ViewModel de l'écran « Profil » : il récupère l'utilisateur et prépare son nom pour la vue.
///
/// J'utilise la macro `@Observable` (iOS 17) plutôt que `ObservableObject` + `@Published` :
/// c'est ce qu'Apple recommande aujourd'hui. Chaque vue ne se redessine que lorsque la
/// propriété qu'elle lit change vraiment, et je n'ai plus besoin de `@Published` partout.
///
/// `@MainActor` garantit que les propriétés sont lues et modifiées sur le thread principal,
/// comme le font les vues SwiftUI, et comme l'exige le `viewContext` de CoreData.
@MainActor
@Observable
final class UserDataViewModel {
    /// Prénom affiché. Vide tant que rien n'a été chargé, ou si le chargement a échoué.
    var firstName: String = ""
    /// Nom de famille affiché.
    var lastName: String = ""
    /// Message à afficher à l'utilisateur si la récupération échoue, `nil` sinon.
    /// La vue l'observe et affiche une alerte dès qu'il n'est plus `nil`.
    var errorMessage: String?

    /// Le contexte CoreData n'est pas une donnée affichée : `@ObservationIgnored` évite que
    /// la macro le surveille pour rien.
    @ObservationIgnored private let viewContext: NSManagedObjectContext

    /// Le contexte est injecté : l'app passe celui de `PersistenceController.shared`,
    /// et les tests celui d'une base en mémoire.
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUserData()
    }

    /// Charge l'utilisateur via le repository.
    ///
    /// Le corrigé de l'énoncé fait un `fatalError()` si l'utilisateur est absent et laisse le
    /// `catch` vide. J'ai préféré renseigner `errorMessage` dans les deux cas : l'app ne
    /// plante pas, et l'utilisateur comprend ce qui se passe.
    private func fetchUserData() {
        do {
            guard let user = try UserRepository(viewContext: viewContext).getUser() else {
                errorMessage = "Aucun utilisateur n'a été trouvé."
                return
            }
            // CoreData génère des propriétés optionnelles (`String?`), même pour un attribut
            // obligatoire : c'est un héritage d'Objective-C. D'où le `?? ""`.
            firstName = user.firstName ?? ""
            lastName = user.lastName ?? ""
        } catch {
            errorMessage = "Impossible de charger les données utilisateur."
        }
    }
}
