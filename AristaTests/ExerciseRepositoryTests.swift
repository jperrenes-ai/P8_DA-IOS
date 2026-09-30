//
//  ExerciseRepositoryTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

@MainActor
struct ExerciseRepositoryTests {
    // MARK: - getExercise

    @Test func getExercise_whenDatabaseIsEmpty_returnsEmptyList() throws {
        let context = TestData.makeContext()

        let exercises = try ExerciseRepository(viewContext: context).getExercise()

        #expect(exercises.isEmpty)
    }

    @Test func getExercise_whenOneExerciseExists_returnsIt() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        try TestData.addExercise(in: context, category: "Football", duration: 10, intensity: 5, startDate: date, user: user)

        let exercises = try ExerciseRepository(viewContext: context).getExercise()

        #expect(exercises.count == 1)
        #expect(exercises.first?.category == "Football")
        #expect(exercises.first?.duration == 10)
        #expect(exercises.first?.intensity == 5)
        #expect(exercises.first?.startDate == date)
    }

    @Test func getExercise_returnsMostRecentFirst() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        try TestData.addExercise(in: context, category: "Football", startDate: today, user: user)
        try TestData.addExercise(in: context, category: "Running", startDate: today.addingTimeInterval(-2 * TestData.oneDay), user: user)
        try TestData.addExercise(in: context, category: "Fitness", startDate: today.addingTimeInterval(-TestData.oneDay), user: user)

        let exercises = try ExerciseRepository(viewContext: context).getExercise()

        #expect(exercises.map(\.category) == ["Football", "Fitness", "Running"])
    }

    // MARK: - addExercise

    @Test func addExercise_savesTheExerciseAndAttachesItToTheUser() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        let repository = ExerciseRepository(viewContext: context)

        try repository.addExercise(category: "Natation", duration: 45, intensity: 7, startDate: date)

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
        let context = TestData.makeContext()
        let repository = ExerciseRepository(viewContext: context)

        #expect(throws: ExerciseRepositoryError.noUserFound) {
            try repository.addExercise(category: "Football", duration: 10, intensity: 5, startDate: Date())
        }
        #expect(try repository.getExercise().isEmpty)
    }

    @Test func noUserFound_hasAReadableMessage() {
        #expect(ExerciseRepositoryError.noUserFound.errorDescription
                == "Aucun utilisateur n'a été trouvé. Impossible d'enregistrer l'exercice.")
    }

    // MARK: - deleteExercise

    @Test func deleteExercise_removesOnlyThatExercise() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let football = try TestData.addExercise(in: context, category: "Football", user: user)
        try TestData.addExercise(in: context, category: "Running", user: user)
        let repository = ExerciseRepository(viewContext: context)

        try repository.deleteExercise(football)

        #expect(try repository.getExercise().map(\.category) == ["Running"])
    }
}
