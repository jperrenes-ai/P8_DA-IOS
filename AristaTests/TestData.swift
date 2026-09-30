//
//  TestData.swift
//  AristaTests
//

import Foundation
import CoreData
@testable import Arista

/// Utilitaires partagés par les tests : création d'une base vierge et insertion directe
/// de données, sans passer par les repositories testés.
enum TestData {
    static let oneDay: TimeInterval = 60 * 60 * 24

    /// Contexte d'une base en mémoire, vierge et propre à chaque appel.
    static func makeContext() -> NSManagedObjectContext {
        PersistenceController(inMemory: true).container.viewContext
    }

    @discardableResult
    static func addUser(
        in context: NSManagedObjectContext,
        firstName: String = "Charlotte",
        lastName: String = "Razoul"
    ) throws -> User {
        let user = User(context: context)
        user.firstName = firstName
        user.lastName = lastName
        try context.save()
        return user
    }

    @discardableResult
    static func addExercise(
        in context: NSManagedObjectContext,
        category: String,
        duration: Int64 = 30,
        intensity: Int64 = 5,
        startDate: Date = Date(),
        user: User
    ) throws -> Exercise {
        let exercise = Exercise(context: context)
        exercise.category = category
        exercise.duration = duration
        exercise.intensity = intensity
        exercise.startDate = startDate
        exercise.user = user
        try context.save()
        return exercise
    }

    @discardableResult
    static func addSleep(
        in context: NSManagedObjectContext,
        startDate: Date,
        duration: Int64 = 480,
        quality: Int64 = 7,
        user: User
    ) throws -> Sleep {
        let sleep = Sleep(context: context)
        sleep.startDate = startDate
        sleep.duration = duration
        sleep.quality = quality
        sleep.user = user
        try context.save()
        return sleep
    }

    /// Laisse en attente dans le contexte un exercice sans utilisateur ni attributs :
    /// toute sauvegarde ultérieure échouera à la validation. C'est le seul moyen fiable
    /// de provoquer une erreur CoreData réelle pour tester les branches `catch`.
    static func insertInvalidPendingObject(in context: NSManagedObjectContext) {
        _ = Exercise(context: context)
    }
}
