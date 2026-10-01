//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData
import Observation

/// ViewModel de l'écran « Sommeil » : il fournit l'historique des nuits, en lecture seule.
///
/// Même construction que `UserDataViewModel` : `@Observable` pour l'observation fine par la
/// vue, et `@MainActor` parce que tout se passe sur le thread principal.
@MainActor
@Observable
final class SleepHistoryViewModel {
    /// Les sessions de sommeil, de la plus récente à la plus ancienne (tri fait par le repository).
    ///
    /// Au départ c'était un tableau de `FakeSleepSession`, une donnée factice en attendant
    /// CoreData. C'est maintenant directement l'entité `Sleep` générée par Xcode.
    var sleepSessions = [Sleep]()
    /// Message à afficher à l'utilisateur si la récupération échoue, `nil` sinon.
    var errorMessage: String?

    @ObservationIgnored private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchSleepSessions()
    }

    /// Charge l'historique. Pas de `reload()` ici : le sommeil n'est jamais modifié par l'app,
    /// donc la liste chargée au démarrage reste à jour.
    private func fetchSleepSessions() {
        do {
            sleepSessions = try SleepRepository(viewContext: viewContext).getSleepSessions()
        } catch {
            errorMessage = "Impossible de charger l'historique de sommeil."
        }
    }
}
