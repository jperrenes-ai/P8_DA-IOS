//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

@MainActor
struct SleepHistoryViewModelTests {
    @Test func init_whenDatabaseIsEmpty_publishesEmptyList() {
        let context = TestData.makeContext()

        let viewModel = SleepHistoryViewModel(context: context)

        #expect(viewModel.sleepSessions.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func init_publishesSessionsMostRecentFirst() throws {
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        let yesterday = today.addingTimeInterval(-TestData.oneDay)
        try TestData.addSleep(in: context, startDate: yesterday, quality: 3, user: user)
        try TestData.addSleep(in: context, startDate: today, quality: 9, user: user)

        let viewModel = SleepHistoryViewModel(context: context)

        #expect(viewModel.sleepSessions.map(\.startDate) == [today, yesterday])
        #expect(viewModel.sleepSessions.map(\.quality) == [9, 3])
        #expect(viewModel.errorMessage == nil)
    }
}
