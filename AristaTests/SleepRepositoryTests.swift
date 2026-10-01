//
//  SleepRepositoryTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

/// Tests de `SleepRepository`.
///
/// Je reprends les trois cas que l'énoncé propose pour les exercices : base vide,
/// un seul élément, et plusieurs éléments pour vérifier le tri.
@MainActor
struct SleepRepositoryTests {
    @Test func getSleepSessions_whenDatabaseIsEmpty_returnsEmptyList() throws {
        // Given
        let context = TestData.makeContext()

        // When
        let sessions = try SleepRepository(viewContext: context).getSleepSessions()

        // Then
        #expect(sessions.isEmpty)
    }

    @Test func getSleepSessions_whenOneSessionExists_returnsIt() throws {
        // Given : une session dont je connais toutes les valeurs
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let date = Date()
        try TestData.addSleep(in: context, startDate: date, duration: 420, quality: 8, user: user)

        // When
        let sessions = try SleepRepository(viewContext: context).getSleepSessions()

        // Then : chaque attribut est relu correctement, y compris la relation vers l'utilisateur
        #expect(sessions.count == 1)
        #expect(sessions.first?.startDate == date)
        #expect(sessions.first?.duration == 420)
        #expect(sessions.first?.quality == 8)
        #expect(sessions.first?.user == user)
    }

    @Test func getSleepSessions_returnsMostRecentFirst() throws {
        // Given : trois nuits insérées volontairement dans le désordre, pour que le test
        // échoue si le repository se contentait de rendre l'ordre d'insertion
        let context = TestData.makeContext()
        let user = try TestData.addUser(in: context)
        let today = Date()
        let yesterday = today.addingTimeInterval(-TestData.oneDay)
        let twoDaysAgo = today.addingTimeInterval(-2 * TestData.oneDay)
        try TestData.addSleep(in: context, startDate: yesterday, user: user)
        try TestData.addSleep(in: context, startDate: twoDaysAgo, user: user)
        try TestData.addSleep(in: context, startDate: today, user: user)

        // When
        let sessions = try SleepRepository(viewContext: context).getSleepSessions()

        // Then : de la plus récente à la plus ancienne
        #expect(sessions.map(\.startDate) == [today, yesterday, twoDaysAgo])
    }
}
