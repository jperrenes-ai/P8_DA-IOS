//
//  DefaultData.swift
//  Arista
//

import Foundation
import CoreData

/// Prépare la base avec les données que le MVP ne permet pas de saisir :
/// l'utilisateur unique et son historique de sommeil.
///
/// L'opération est idempotente : chaque bloc ne s'exécute que si la donnée
/// correspondante est absente, afin que les lancements suivants ne dupliquent rien.
struct DefaultData {
    let viewContext: NSManagedObjectContext

    /// Nombre de sessions de sommeil générées à l'initialisation.
    private static let sleepSessionCount = 5

    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }

    func apply() throws {
        let userRepository = UserRepository(viewContext: viewContext)
        let sleepRepository = SleepRepository(viewContext: viewContext)

        let user = try userRepository.getUser() ?? makeInitialUser()

        if try sleepRepository.getSleepSessions().isEmpty {
            makeInitialSleepSessions(for: user)
        }

        if viewContext.hasChanges {
            try viewContext.save()
        }
    }

    private func makeInitialUser() -> User {
        let user = User(context: viewContext)
        user.firstName = "Charlotte"
        user.lastName = "Razoul"
        return user
    }

    private func makeInitialSleepSessions(for user: User) {
        let oneDay: TimeInterval = 60 * 60 * 24

        // Les sessions sont datées dans le passé, la plus ancienne en premier,
        // pour que l'historique affiché soit cohérent au premier lancement.
        for dayOffset in 1...Self.sleepSessionCount {
            let session = Sleep(context: viewContext)
            session.duration = Int64((0...900).randomElement()!)
            session.quality = Int64((0...10).randomElement()!)
            session.startDate = Date(timeIntervalSinceNow: -oneDay * Double(dayOffset))
            session.user = user
        }
    }
}
