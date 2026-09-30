//
//  UserRepositoryTests.swift
//  AristaTests
//

import Testing
@testable import Arista

@MainActor
struct UserRepositoryTests {
    @Test func getUser_whenDatabaseIsEmpty_returnsNil() throws {
        let context = TestData.makeContext()

        let user = try UserRepository(viewContext: context).getUser()

        #expect(user == nil)
    }

    @Test func getUser_whenAUserExists_returnsIt() throws {
        let context = TestData.makeContext()
        try TestData.addUser(in: context, firstName: "Eric", lastName: "Marcus")

        let user = try UserRepository(viewContext: context).getUser()

        #expect(user?.firstName == "Eric")
        #expect(user?.lastName == "Marcus")
    }
}
