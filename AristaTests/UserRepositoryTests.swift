//
//  UserRepositoryTests.swift
//  AristaTests
//

import Testing
@testable import Arista

/// Tests de `UserRepository`.
///
/// J'utilise Swift Testing (`@Test`, `#expect`) plutôt que XCTest : c'est le framework de test
/// actuel d'Apple, plus concis, et il ne demande pas Combine pour lire les valeurs.
///
/// `@MainActor` : Swift Testing lance les tests en parallèle, sur plusieurs threads. Or le
/// `viewContext` de CoreData ne doit être utilisé que sur le thread principal. Cette annotation
/// garantit que chaque test s'exécute dessus.
///
/// Tous les tests suivent le même schéma, en trois temps :
/// 1. **Given** : la situation de départ (souvent une base vierge, plus quelques données) ;
/// 2. **When** : l'appel de la méthode testée ;
/// 3. **Then** : la vérification du résultat.
@MainActor
struct UserRepositoryTests {
    @Test func getUser_whenDatabaseIsEmpty_returnsNil() throws {
        // Given : une base vierge
        let context = TestData.makeContext()

        // When
        let user = try UserRepository(viewContext: context).getUser()

        // Then : pas d'utilisateur, et surtout pas de crash
        #expect(user == nil)
    }

    @Test func getUser_whenAUserExists_returnsIt() throws {
        // Given : un utilisateur avec un nom différent de celui de `DefaultData`,
        // pour être sûr que c'est bien lui qui est retourné
        let context = TestData.makeContext()
        try TestData.addUser(in: context, firstName: "Eric", lastName: "Marcus")

        // When
        let user = try UserRepository(viewContext: context).getUser()

        // Then
        #expect(user?.firstName == "Eric")
        #expect(user?.lastName == "Marcus")
    }
}
