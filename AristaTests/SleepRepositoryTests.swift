//
//  SleepRepositoryTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

@MainActor
struct SleepRepositoryTests {
    @Test func getSleepSessions_whenDatabaseIsEmpty_returnsEmptyList() throws {
        let context = TestData.makeContext()

        let sessions = try SleepRepository(viewContext: context).getSleepSessions()

        #expect(sessions.isEmpty)
    }

    @Test func getSleepSessions_whenOneSessionExists_returnsIt() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        try TestData.addSleep(in: context, startDate: date, duration: 420, quality: 8, user: user)

        let sessions = try SleepRepository(viewContext: context).getSleepSessions()

        #expect(sessions.count == 1)
        #expect(sessions.first?.startDate == date)
        #expect(sessions.first?.duration == 420)
        #expect(sessions.first?.quality == 8)
        #expect(sessions.first?.user == user)
    }

    @Test func getSleepSessions_returnsMostRecentFirst() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        let yesterday = today.addingTimeInterval(-TestData.oneDay)
        let twoDaysAgo = today.addingTimeInterval(-2 * TestData.oneDay)
        // Insérées volontairement dans le désordre
        try TestData.addSleep(in: context, startDate: yesterday, user: user)
        try TestData.addSleep(in: context, startDate: twoDaysAgo, user: user)
        try TestData.addSleep(in: context, startDate: today, user: user)

        let sessions = try SleepRepository(viewContext: context).getSleepSessions()

        #expect(sessions.map(\.startDate) == [today, yesterday, twoDaysAgo])
    }
}
