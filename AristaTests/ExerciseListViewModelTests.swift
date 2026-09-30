//
//  ExerciseListViewModelTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

@MainActor
struct ExerciseListViewModelTests {
    @Test func init_whenDatabaseIsEmpty_publishesEmptyList() {
        let context = TestData.makeContext()

        let viewModel = ExerciseListViewModel(context: context)

        #expect(viewModel.exercises.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func init_whenOneExerciseExists_publishesIt() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        try TestData.addExercise(in: context, category: "Football", duration: 10, intensity: 5, startDate: date, user: user)

        let viewModel = ExerciseListViewModel(context: context)

        #expect(viewModel.exercises.count == 1)
        #expect(viewModel.exercises.first?.category == "Football")
        #expect(viewModel.exercises.first?.duration == 10)
        #expect(viewModel.exercises.first?.intensity == 5)
        #expect(viewModel.exercises.first?.startDate == date)
    }

    @Test func init_publishesExercisesMostRecentFirst() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        try TestData.addExercise(in: context, category: "Football", startDate: today, user: user)
        try TestData.addExercise(in: context, category: "Running", startDate: today.addingTimeInterval(-2 * TestData.oneDay), user: user)
        try TestData.addExercise(in: context, category: "Fitness", startDate: today.addingTimeInterval(-TestData.oneDay), user: user)

        let viewModel = ExerciseListViewModel(context: context)

        #expect(viewModel.exercises.map(\.category) == ["Football", "Fitness", "Running"])
    }

    @Test func reload_picksUpExercisesAddedAfterInit() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let viewModel = ExerciseListViewModel(context: context)
        try TestData.addExercise(in: context, category: "Running", user: user)
        #expect(viewModel.exercises.isEmpty)

        viewModel.reload()

        #expect(viewModel.exercises.map(\.category) == ["Running"])
    }

    @Test func deleteExercises_removesTheExerciseAtTheGivenOffset() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        try TestData.addExercise(in: context, category: "Football", startDate: today, user: user)
        try TestData.addExercise(in: context, category: "Running", startDate: today.addingTimeInterval(-TestData.oneDay), user: user)
        let viewModel = ExerciseListViewModel(context: context)

        viewModel.deleteExercises(at: IndexSet(integer: 0))

        #expect(viewModel.exercises.map(\.category) == ["Running"])
        #expect(try ExerciseRepository(viewContext: context).getExercise().count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func deleteExercises_whenSaveFails_publishesAnError() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        try TestData.addExercise(in: context, category: "Football", user: user)
        let viewModel = ExerciseListViewModel(context: context)
        TestData.insertInvalidPendingObject(in: context)

        viewModel.deleteExercises(at: IndexSet(integer: 0))

        #expect(viewModel.errorMessage == "Impossible de supprimer l'exercice.")
    }
}
