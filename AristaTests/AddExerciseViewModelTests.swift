//
//  AddExerciseViewModelTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

/// Tests de `AddExerciseViewModel` : validation en temps réel et enregistrement.
@MainActor
struct AddExerciseViewModelTests {
    // MARK: - Validation

    @Test func newForm_isInvalidUntilACategoryIsChosen() {
        // Given / When : un formulaire tout juste ouvert
        let viewModel = AddExerciseViewModel(context: TestData.makeContext())

        // Then : la catégorie est vide par défaut, le bouton « Ajouter » doit être grisé
        #expect(viewModel.isValid == false)
        #expect(viewModel.validationError == .invalidCategory)
    }

    @Test func form_withAllFieldsCorrect_isValid() {
        let viewModel = AddExerciseViewModel(context: TestData.makeContext())

        viewModel.category = ExerciseCategory.running.rawValue

        // Les valeurs par défaut (30 min, intensité 5, maintenant) sont déjà valides
        #expect(viewModel.isValid)
        #expect(viewModel.validationError == nil)
    }

    @Test func form_withAFutureDate_isInvalid() {
        let viewModel = AddExerciseViewModel(context: TestData.makeContext())
        viewModel.category = ExerciseCategory.running.rawValue

        viewModel.startTime = Date().addingTimeInterval(60 * 60)

        #expect(viewModel.validationError == .startDateInFuture)
    }

    @Test func addExercise_whenFormIsInvalid_returnsFalseAndSavesNothing() throws {
        // Given : un utilisateur existe, mais la durée est à 0
        let context = TestData.makeContext()
        try TestData.addUser(in: context)
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = ExerciseCategory.football.rawValue
        viewModel.duration = 0

        // When
        let succeeded = viewModel.addExercise()

        // Then : refusé, avec le message de la règle concernée
        #expect(succeeded == false)
        #expect(viewModel.errorMessage == ExerciseValidationError.invalidDuration.errorDescription)
        #expect(try ExerciseRepository(viewContext: context).getExercise().isEmpty)
    }

    // MARK: - Enregistrement

    @Test func addExercise_withAUser_savesTheExerciseAndReturnsTrue() throws {
        // Given : un formulaire correctement rempli
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Football"
        viewModel.duration = 45
        viewModel.intensity = 7
        viewModel.startTime = date

        // When
        let succeeded = viewModel.addExercise()

        // Then : la vue peut se fermer, et l'exercice est en base avec les bonnes valeurs
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
        // Given : saisie valide, mais aucun utilisateur en base
        let context = TestData.makeContext()
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Football"

        // When
        let succeeded = viewModel.addExercise()

        // Then : la vue reste ouverte et affiche le message métier, compréhensible
        #expect(succeeded == false)
        #expect(viewModel.errorMessage == ExerciseRepositoryError.noUserFound.errorDescription)
        #expect(try ExerciseRepository(viewContext: context).getExercise().isEmpty)
    }

    @Test func addExercise_whenSaveFails_returnsFalseWithAGenericMessage() throws {
        // Given : saisie valide et utilisateur présent, mais un objet invalide fera échouer
        // la sauvegarde CoreData
        let context = TestData.makeContext()
        try TestData.addUser(in: context)
        TestData.insertInvalidPendingObject(in: context)
        let viewModel = AddExerciseViewModel(context: context)
        viewModel.category = "Football"

        // When
        let succeeded = viewModel.addExercise()

        // Then : l'erreur technique de CoreData n'est pas montrée telle quelle,
        // l'utilisateur voit un message générique
        #expect(succeeded == false)
        #expect(viewModel.errorMessage == "Impossible d'enregistrer l'exercice.")
    }
}
