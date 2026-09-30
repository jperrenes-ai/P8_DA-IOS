//
//  DefaultDataTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

@MainActor
struct DefaultDataTests {
    @Test func apply_onEmptyDatabase_createsTheUserAndFiveSleepSessions() throws {
        let context = TestData.makeContext()

        try DefaultData(viewContext: context).apply()

        let user = try UserRepository(viewContext: context).getUser()
        let sessions = try SleepRepository(viewContext: context).getSleepSessions()
        #expect(user?.firstName == "Charlotte")
        #expect(user?.lastName == "Razoul")
        #expect(sessions.count == 5)
        #expect(sessions.allSatisfy { $0.user == user })
        #expect(sessions.allSatisfy { (0...900).contains($0.duration) })
        #expect(sessions.allSatisfy { (0...10).contains($0.quality) })
        #expect(context.hasChanges == false)
    }

    @Test func apply_datesAllSleepSessionsInThePast() throws {
        let context = TestData.makeContext()

        try DefaultData(viewContext: context).apply()

        let now = Date()
        let sessions = try SleepRepository(viewContext: context).getSleepSessions()
        #expect(sessions.allSatisfy { ($0.startDate ?? now) < now })
    }

    @Test func apply_calledTwice_doesNotDuplicateData() throws {
        let context = TestData.makeContext()
        let defaultData = DefaultData(viewContext: context)

        try defaultData.apply()
        try defaultData.apply()

        #expect(try context.count(for: User.fetchRequest()) == 1)
        #expect(try context.count(for: Sleep.fetchRequest()) == 5)
    }

    @Test func apply_whenAUserAlreadyExists_keepsItAndAttachesTheSessionsToIt() throws {
        let context = TestData.makeContext()
        let existing = try TestData.addUser(in: context, firstName: "Eric", lastName: "Marcus")

        try DefaultData(viewContext: context).apply()

        let sessions = try SleepRepository(viewContext: context).getSleepSessions()
        #expect(try context.count(for: User.fetchRequest()) == 1)
        #expect(try UserRepository(viewContext: context).getUser()?.firstName == "Eric")
        #expect(sessions.count == 5)
        #expect(sessions.allSatisfy { $0.user == existing })
    }

    @Test func apply_whenSleepSessionsAlreadyExist_doesNotAddAny() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        try TestData.addSleep(in: context, startDate: Date(), user: user)

        try DefaultData(viewContext: context).apply()

        #expect(try context.count(for: Sleep.fetchRequest()) == 1)
    }

    // MARK: - Intégration avec PersistenceController

    @Test func inMemoryController_startsWithAnEmptyDatabase() throws {
        let context = PersistenceController(inMemory: true).container.viewContext

        #expect(try context.count(for: User.fetchRequest()) == 0)
        #expect(try context.count(for: Sleep.fetchRequest()) == 0)
    }

    @Test func previewController_containsTheDefaultData() throws {
        let context = PersistenceController.preview.container.viewContext

        #expect(try UserRepository(viewContext: context).getUser() != nil)
        #expect(try SleepRepository(viewContext: context).getSleepSessions().count == 5)
    }
}
