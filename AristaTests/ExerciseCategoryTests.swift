//
//  ExerciseCategoryTests.swift
//  AristaTests
//

import Testing
@testable import Arista

/// Tests de `ExerciseCategory`, en particulier la correspondance avec les valeurs stockées.
struct ExerciseCategoryTests {
    @Test func symbolName_forAKnownStoredCategory_returnsItsSymbol() {
        #expect(ExerciseCategory.symbolName(for: "Football") == ExerciseCategory.football.symbolName)
    }

    @Test(arguments: [nil, "", "Pétanque"] as [String?])
    func symbolName_forAnUnknownOrMissingCategory_returnsTheDefaultSymbol(stored: String?) {
        // Cas d'un exercice enregistré avant la liste de catégories, ou d'un attribut vide
        #expect(ExerciseCategory.symbolName(for: stored) == ExerciseCategory.unknownSymbolName)
    }

    @Test func everyCategory_hasADistinctSymbol() {
        // Deux catégories avec la même icône seraient indiscernables dans la liste
        let symbols = ExerciseCategory.allCases.map(\.symbolName)
        #expect(Set(symbols).count == symbols.count)
    }

    @Test func id_isTheStoredRawValue() {
        // L'`id` sert d'identité dans le `Picker` : il doit être unique et stable
        for category in ExerciseCategory.allCases {
            #expect(category.id == category.rawValue)
        }
    }
}
