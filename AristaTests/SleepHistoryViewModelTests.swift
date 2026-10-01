//
//  SleepHistoryViewModelTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

/// Tests de `SleepHistoryViewModel`.
@MainActor
struct SleepHistoryViewModelTests {
    @Test func init_whenDatabaseIsEmpty_publishesEmptyList() {
        // Given
        let context = TestData.makeContext()

        // When
        let viewModel = SleepHistoryViewModel(context: context)

        // Then : une liste vide n'est pas une erreur
        #expect(viewModel.sleepSessions.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func init_publishesSessionsMostRecentFirst() throws {
        // Given : deux nuits insérées de la plus ancienne à la plus récente
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        let yesterday = today.addingTimeInterval(-TestData.oneDay)
        try TestData.addSleep(in: context, startDate: yesterday, quality: 3, user: user)
        try TestData.addSleep(in: context, startDate: today, quality: 9, user: user)

        // When
        let viewModel = SleepHistoryViewModel(context: context)

        // Then : le ViewModel expose bien la liste triée par le repository
        #expect(viewModel.sleepSessions.map(\.startDate) == [today, yesterday])
        #expect(viewModel.sleepSessions.map(\.quality) == [9, 3])
        #expect(viewModel.errorMessage == nil)
    }
}
