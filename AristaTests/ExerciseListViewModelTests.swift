//
//  ExerciseListViewModelTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

/// Tests de `ExerciseListViewModel` : chargement, rechargement et suppression.
@MainActor
struct ExerciseListViewModelTests {
    @Test func init_whenDatabaseIsEmpty_publishesEmptyList() {
        // Given
        let context = TestData.makeContext()

        // When
        let viewModel = ExerciseListViewModel(context: context)

        // Then
        #expect(viewModel.exercises.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func init_whenOneExerciseExists_publishesIt() throws {
        // Given
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        try TestData.addExercise(in: context, category: "Football", duration: 10, intensity: 5, startDate: date, user: user)

        // When
        let viewModel = ExerciseListViewModel(context: context)

        // Then
        #expect(viewModel.exercises.count == 1)
        #expect(viewModel.exercises.first?.category == "Football")
        #expect(viewModel.exercises.first?.duration == 10)
        #expect(viewModel.exercises.first?.intensity == 5)
        #expect(viewModel.exercises.first?.startDate == date)
    }

    @Test func init_publishesExercisesMostRecentFirst() throws {
        // Given : même jeu de données que le test du corrigé
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        try TestData.addExercise(in: context, category: "Football", startDate: today, user: user)
        try TestData.addExercise(in: context, category: "Running", startDate: today.addingTimeInterval(-2 * TestData.oneDay), user: user)
        try TestData.addExercise(in: context, category: "Fitness", startDate: today.addingTimeInterval(-TestData.oneDay), user: user)

        // When
        let viewModel = ExerciseListViewModel(context: context)

        // Then
        #expect(viewModel.exercises.map(\.category) == ["Football", "Fitness", "Running"])
    }

    @Test func reload_picksUpExercisesAddedAfterInit() throws {
        // Given : le ViewModel est créé AVANT l'ajout de l'exercice — c'est la situation de
        // l'app, où la liste existe déjà quand on revient du formulaire d'ajout
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let viewModel = ExerciseListViewModel(context: context)
        try TestData.addExercise(in: context, category: "Running", user: user)
        // Sans rechargement, la liste ne voit pas le nouvel exercice : c'était le bug de l'énoncé
        #expect(viewModel.exercises.isEmpty)

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.exercises.map(\.category) == ["Running"])
    }

    @Test func deleteExercises_removesTheExerciseAtTheGivenOffset() throws {
        // Given : Football (le plus récent, donc en position 0) puis Running
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        try TestData.addExercise(in: context, category: "Football", startDate: today, user: user)
        try TestData.addExercise(in: context, category: "Running", startDate: today.addingTimeInterval(-TestData.oneDay), user: user)
        let viewModel = ExerciseListViewModel(context: context)

        // When : je simule ce que fait `.onDelete` quand on glisse la première ligne
        viewModel.deleteExercises(at: IndexSet(integer: 0))

        // Then : la liste publiée ET la base sont à jour
        #expect(viewModel.exercises.map(\.category) == ["Running"])
        #expect(try ExerciseRepository(viewContext: context).getExercise().count == 1)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func deleteExercises_whenSaveFails_publishesAnError() throws {
        // Given : un exercice, puis un objet invalide qui fera échouer la sauvegarde
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        try TestData.addExercise(in: context, category: "Football", user: user)
        let viewModel = ExerciseListViewModel(context: context)
        TestData.insertInvalidPendingObject(in: context)

        // When
        viewModel.deleteExercises(at: IndexSet(integer: 0))

        // Then : l'échec n'est pas silencieux
        #expect(viewModel.errorMessage == "Impossible de supprimer l'exercice.")
    }
}
