//
//  DefaultData.swift
//  Arista
//

import Foundation
import CoreData

/// Prépare la base avec les données que le MVP ne permet pas de saisir :
/// l'utilisateur unique et son historique de sommeil.
///
/// C'est appelé une fois au démarrage, à la fin de l'`init` de `PersistenceController`
/// (uniquement pour la vraie base, pas pour les bases en mémoire des tests).
///
/// L'opération est **idempotente** : chaque bloc ne s'exécute que si la donnée est absente.
/// Sans ça, on ajouterait 5 nouvelles sessions de sommeil à chaque lancement de l'app.
struct DefaultData {
    let viewContext: NSManagedObjectContext

    /// Nombre de sessions de sommeil générées à l'initialisation.
    private static let sleepSessionCount = 5

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    /// Insère l'utilisateur et les sessions de sommeil s'ils n'existent pas encore.
    ///
    /// Je réutilise les repositories pour savoir ce qui existe déjà, plutôt que de refaire
    /// des requêtes ici : une seule façon de lire les données dans tout le projet.
    func apply() throws {
        let userRepository = UserRepository(viewContext: viewContext)
        let sleepRepository = SleepRepository(viewContext: viewContext)

        // Si un utilisateur existe déjà, je le garde ; sinon j'en crée un.
        // Dans les deux cas j'ai un `user` sous la main pour y rattacher les sessions.
        let user = try userRepository.getUser() ?? makeInitialUser()

        if try sleepRepository.getSleepSessions().isEmpty {
            makeInitialSleepSessions(for: user)
        }

        // Je ne sauvegarde que s'il y a vraiment quelque chose de nouveau :
        // au deuxième lancement, rien n'a changé et on évite une écriture inutile.
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    /// Crée l'utilisateur par défaut demandé par l'énoncé.
    private func makeInitialUser() -> User {
        let user = User(context: viewContext)
        user.firstName = "Charlotte"
        user.lastName = "Razoul"
        return user
    }

    /// Crée une session de sommeil par nuit sur les derniers jours (hier, avant-hier…).
    ///
    /// J'ai remplacé les cinq blocs `sleep1`…`sleep5` du corrigé par une boucle : c'est le
    /// même résultat, en évitant de copier-coller cinq fois les mêmes lignes.
    ///
    /// J'ai aussi corrigé une erreur du corrigé : il utilise `Date(timeIntervalSinceNow:)`
    /// avec une valeur **positive**, ce qui place les nuits dans le futur. Ici le décalage
    /// est négatif, donc toutes les sessions sont bien dans le passé.
    private func makeInitialSleepSessions(for user: User) {
        let oneDay: TimeInterval = 60 * 60 * 24

        for dayOffset in 1...Self.sleepSessionCount {
            let session = Sleep(context: viewContext)
            // Durée en minutes (entre 0 et 15 h) et qualité notée de 0 à 10, tirées au hasard
            // comme dans le corrigé. `Int64(...)` car CoreData stocke des `Integer 64`.
            session.duration = Int64((0...900).randomElement()!)
            session.quality = Int64((0...10).randomElement()!)
            session.startDate = Date(timeIntervalSinceNow: -oneDay * Double(dayOffset))
            session.user = user
        }
    }
}
