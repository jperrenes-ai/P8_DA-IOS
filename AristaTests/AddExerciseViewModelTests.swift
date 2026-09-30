//
//  AddExerciseViewModelTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

@MainActor
struct AddExerciseViewModelTests {
    @Test func addExercise_withAUser_savesTheExerciseAndReturnsTrue() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Football"
        viewModel.duration = 45
        viewModel.intensity = 7
        viewModel.startTime = date

        let succeeded = viewModel.addExercise()

        let exercises = try ExerciseRepository(viewContext: context).getExercise()
        #expect(succeeded)
        #expect(viewModel.errorMessage == nil)
        #expect(exercises.count == 1)
        #expect(exercises.first?.category == "Football")
        #expect(exercises.first?.duration == 45)
        #expect(exercises.first?.intensity == 7)
        #expect(exercises.first?.startDate == date)
        #expect(exercises.first?.user == user)
    }

    @Test func addExercise_whenNoUserExists_returnsFalseWithTheBusinessMessage() throws {
        let context = TestData.makeContext()
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Football"

        let succeeded = viewModel.addExercise()

        #expect(succeeded == false)
        #expect(viewModel.errorMessage == ExerciseRepositoryError.noUserFound.errorDescription)
        #expect(try ExerciseRepository(viewContext: context).getExercise().isEmpty)
    }

    @Test func addExercise_whenSaveFails_returnsFalseWithAGenericMessage() throws {
        let context = TestData.makeContext()
        try TestData.addUser(in: context)
        TestData.insertInvalidPendingObject(in: context)
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Football"

        let succeeded = viewModel.addExercise()

        #expect(succeeded == false)
        #expect(viewModel.errorMessage == "Impossible d'enregistrer l'exercice.")
    }
}
