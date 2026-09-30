//
//  UserDataViewModelTests.swift
//  AristaTests
//

import Testing
@testable import Arista

@MainActor
struct UserDataViewModelTests {
    @Test func init_whenAUserExists_publishesItsNames() throws {
        let context = TestData.makeContext()
        try TestData.addUser(in: context, firstName: "Eric", lastName: "Marcus")

        let viewModel = UserDataViewModel(context: context)

        #expect(viewModel.firstName == "Eric")
        #expect(viewModel.lastName == "Marcus")
        #expect(viewModel.errorMessage == nil)
    }

    @Test func init_whenNoUserExists_publishesAnError() {
        let context = TestData.makeContext()

        let viewModel = UserDataViewModel(context: context)

        #expect(viewModel.firstName.isEmpty)
        #expect(viewModel.lastName.isEmpty)
        #expect(viewModel.errorMessage == "Aucun utilisateur n'a été trouvé.")
    }
}
