//
//  UserDataViewModelTests.swift
//  AristaTests
//

import Testing
@testable import Arista

/// Tests de `UserDataViewModel`.
///
/// Le corrigé de l'énoncé teste les ViewModels avec Combine (`$exercises.sink` +
/// `XCTestExpectation`). Ce n'est pas nécessaire ici : le chargement se fait de façon
/// synchrone dans l'`init`, donc les propriétés sont déjà à jour juste après la création
/// du ViewModel, et je peux les lire directement.
@MainActor
struct UserDataViewModelTests {
    @Test func init_whenAUserExists_publishesItsNames() throws {
        // Given
        let context = TestData.makeContext()
        try TestData.addUser(in: context, firstName: "Eric", lastName: "Marcus")

        // When
        let viewModel = UserDataViewModel(context: context)

        // Then
        #expect(viewModel.firstName == "Eric")
        #expect(viewModel.lastName == "Marcus")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func init_whenNoUserExists_publishesAnError() {
        // Given : base vide — c'est le cas où le corrigé faisait un `fatalError()`
        let context = TestData.makeContext()

        // When
        let viewModel = UserDataViewModel(context: context)

        // Then : pas de crash, des noms vides et un message pour l'utilisateur
        #expect(viewModel.firstName.isEmpty)
        #expect(viewModel.lastName.isEmpty)
        #expect(viewModel.errorMessage == "Aucun utilisateur n'a été trouvé.")
    }
}
