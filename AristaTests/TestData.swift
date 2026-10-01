//
//  TestData.swift
//  AristaTests
//

import Foundation
import CoreData
@testable import Arista

/// Utilitaires partagés par tous les tests.
///
/// Deux idées guident ce fichier :
/// 1. **Chaque test part d'une base vierge.** `makeContext()` crée à chaque appel une nouvelle
///    base en mémoire, isolée des autres. Un test ne peut donc jamais être influencé par ce
///    qu'un autre a laissé derrière lui, et les tests peuvent tourner en parallèle.
/// 2. **Les données de départ sont insérées directement**, sans passer par les repositories.
///    Si je testais `getExercise()` en ajoutant les exercices avec `addExercise()`, un bug dans
///    `addExercise()` pourrait masquer (ou provoquer) un échec de `getExercise()`. En insérant
///    « à la main », chaque test ne vérifie qu'une seule méthode.
///
/// C'est l'équivalent des fonctions `emptyEntities` et `addExercice` du corrigé, regroupées
/// ici pour ne pas les recopier dans chaque fichier de test.
enum TestData {
    static let oneDay: TimeInterval = 60 * 60 * 24

    /// Contexte d'une base en mémoire, vierge et propre à chaque appel.
    ///
    /// Le corrigé vide la base avec `emptyEntities` au début de chaque test ; ici ce n'est pas
    /// nécessaire, puisque la base est neuve (et `PersistenceController` n'y insère pas les
    /// données par défaut quand `inMemory` vaut `true`).
    static func makeContext() -> NSManagedObjectContext {
        PersistenceController(inMemory: true).container.viewContext
    }

    /// Insère et sauvegarde un utilisateur. Les valeurs par défaut évitent d'avoir à les
    /// répéter dans les tests où le nom n'a pas d'importance.
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

    /// Insère et sauvegarde un exercice rattaché à `user`.
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

    /// Insère et sauvegarde une session de sommeil rattachée à `user`.
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

    /// Laisse en attente dans le contexte un exercice sans utilisateur ni attributs.
    ///
    /// L'énoncé explique qu'on ne peut pas tester les échecs de CoreData lui-même. C'est vrai
    /// pour les lectures, mais pas pour les sauvegardes : un `save()` enregistre *tous* les
    /// changements en attente, et échoue si l'un d'eux est invalide. En laissant traîner cet
    /// objet invalide, la prochaine sauvegarde (ajout ou suppression) échoue pour de vrai, ce
    /// qui me permet de vérifier que le ViewModel affiche bien un message d'erreur.
    static func insertInvalidPendingObject(in context: NSManagedObjectContext) {
        _ = Exercise(context: context)
    }
}
