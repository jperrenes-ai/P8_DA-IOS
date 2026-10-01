//
//  ExerciseRepositoryTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

/// Tests de `ExerciseRepository` : lecture, ajout (avec ses cas d'erreur) et suppression.
@MainActor
struct ExerciseRepositoryTests {
    // MARK: - getExercise

    @Test func getExercise_whenDatabaseIsEmpty_returnsEmptyList() throws {
        // Given
        let context = TestData.makeContext()

        // When
        let exercises = try ExerciseRepository(viewContext: context).getExercise()

        // Then
        #expect(exercises.isEmpty)
    }

    @Test func getExercise_whenOneExerciseExists_returnsIt() throws {
        // Given
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        try TestData.addExercise(in: context, category: "Football", duration: 10, intensity: 5, startDate: date, user: user)

        // When
        let exercises = try ExerciseRepository(viewContext: context).getExercise()

        // Then
        #expect(exercises.count == 1)
        #expect(exercises.first?.category == "Football")
        #expect(exercises.first?.duration == 10)
        #expect(exercises.first?.intensity == 5)
        #expect(exercises.first?.startDate == date)
    }

    @Test func getExercise_returnsMostRecentFirst() throws {
        // Given : le même jeu de données que dans le corrigé (Football aujourd'hui,
        // Fitness hier, Running avant-hier), inséré dans le désordre
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        try TestData.addExercise(in: context, category: "Football", startDate: today, user: user)
        try TestData.addExercise(in: context, category: "Running", startDate: today.addingTimeInterval(-2 * TestData.oneDay), user: user)
        try TestData.addExercise(in: context, category: "Fitness", startDate: today.addingTimeInterval(-TestData.oneDay), user: user)

        // When
        let exercises = try ExerciseRepository(viewContext: context).getExercise()

        // Then
        #expect(exercises.map(\.category) == ["Football", "Fitness", "Running"])
    }

    // MARK: - addExercise

    @Test func addExercise_savesTheExerciseAndAttachesItToTheUser() throws {
        // Given
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        let repository = ExerciseRepository(viewContext: context)

        // When
        try repository.addExercise(category: "Natation", duration: 45, intensity: 7, startDate: date)

        // Then : l'exercice est relu avec les bonnes valeurs, rattaché à l'utilisateur,
        // et `hasChanges == false` prouve qu'il a bien été sauvegardé (pas seulement créé)
        let exercises = try repository.getExercise()
        #expect(exercises.count == 1)
        #expect(exercises.first?.category == "Natation")
        #expect(exercises.first?.duration == 45)
        #expect(exercises.first?.intensity == 7)
        #expect(exercises.first?.startDate == date)
        #expect(exercises.first?.user == user)
        #expect(context.hasChanges == false)
    }

    @Test func addExercise_whenNoUserExists_throwsNoUserFound() throws {
        // Given : une base sans utilisateur
        let context = TestData.makeContext()
        let repository = ExerciseRepository(viewContext: context)

        // When / Then : l'erreur précise est levée…
        #expect(throws: ExerciseRepositoryError.noUserFound) {
            try repository.addExercise(category: "Football", duration: 10, intensity: 5, startDate: Date())
        }
        // … et rien n'a été enregistré
        #expect(try repository.getExercise().isEmpty)
    }

    @Test func addExercise_whenDataIsInvalid_throwsTheValidationErrorAndSavesNothing() throws {
        // Given : un utilisateur existe, donc seule la validation peut faire échouer l'ajout
        let context = TestData.makeContext()
        try TestData.addUser(in: context)
        let repository = ExerciseRepository(viewContext: context)

        // When / Then : la règle est appliquée par le Model lui-même, pas seulement par le formulaire
        #expect(throws: ExerciseValidationError.invalidCategory) {
            try repository.addExercise(category: "", duration: 10, intensity: 5, startDate: Date())
        }
        #expect(try repository.getExercise().isEmpty)
        // Rien ne reste en attente dans le contexte : la validation a lieu avant toute création
        #expect(context.hasChanges == false)
    }

    @Test func noUserFound_hasAReadableMessage() {
        // Ce message est affiché tel quel à l'utilisateur : je vérifie qu'il est bien rédigé
        #expect(ExerciseRepositoryError.noUserFound.errorDescription
                == "Aucun utilisateur n'a été trouvé. Impossible d'enregistrer l'exercice.")
    }

    // MARK: - deleteExercise

    @Test func deleteExercise_removesOnlyThatExercise() throws {
        // Given : deux exercices
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let football = try TestData.addExercise(in: context, category: "Football", user: user)
        try TestData.addExercise(in: context, category: "Running", user: user)
        let repository = ExerciseRepository(viewContext: context)

        // When : j'en supprime un
        try repository.deleteExercise(football)

        // Then : seul l'autre reste
        #expect(try repository.getExercise().map(\.category) == ["Running"])
    }
}
