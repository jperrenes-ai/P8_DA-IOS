//
//  ExerciseValidatorTests.swift
//  AristaTests
//

import Foundation
import Testing
@testable import Arista

/// Tests des règles de validation d'un exercice.
///
/// Ces règles protègent la base (elles sont appliquées par le repository), donc je teste
/// chaque règle séparément, y compris aux bornes exactes : c'est souvent là que se cachent
/// les erreurs (`<` au lieu de `<=`, par exemple).
struct ExerciseValidatorTests {
    /// Une date fixe sert de « maintenant » : le résultat ne dépend pas de l'horloge.
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    /// Raccourci : valide un exercice dont seuls les champs précisés changent.
    private func validate(
        category: String = ExerciseCategory.running.rawValue,
        duration: Int = 30,
        intensity: Int = 5,
        startDate: Date? = nil
    ) throws {
        try ExerciseValidator.validate(
            category: category,
            duration: duration,
            intensity: intensity,
            startDate: startDate ?? now,
            now: now
        )
    }

    @Test func validExercise_passes() throws {
        try validate()
    }

    // MARK: - Catégorie

    @Test(arguments: ["", "Foot", "football"])
    func unknownOrEmptyCategory_isRejected(category: String) {
        // `arguments:` lance ce test une fois par valeur. "football" en minuscules est refusé :
        // seules les valeurs exactes de `ExerciseCategory` sont acceptées.
        #expect(throws: ExerciseValidationError.invalidCategory) {
            try validate(category: category)
        }
    }

    @Test func everyKnownCategory_isAccepted() throws {
        for category in ExerciseCategory.allCases {
            try validate(category: category.rawValue)
        }
    }

    // MARK: - Durée

    @Test(arguments: [0, -10, 1441])
    func durationOutOfRange_isRejected(duration: Int) {
        #expect(throws: ExerciseValidationError.invalidDuration) {
            try validate(duration: duration)
        }
    }

    @Test(arguments: [1, 1440])
    func durationAtTheBounds_isAccepted(duration: Int) throws {
        try validate(duration: duration)
    }

    // MARK: - Intensité

    @Test(arguments: [-1, 11])
    func intensityOutOfRange_isRejected(intensity: Int) {
        #expect(throws: ExerciseValidationError.invalidIntensity) {
            try validate(intensity: intensity)
        }
    }

    @Test(arguments: [0, 10])
    func intensityAtTheBounds_isAccepted(intensity: Int) throws {
        try validate(intensity: intensity)
    }

    // MARK: - Date

    @Test func startDateInTheFuture_isRejected() {
        #expect(throws: ExerciseValidationError.startDateInFuture) {
            try validate(startDate: now.addingTimeInterval(1))
        }
    }

    @Test func startDateExactlyNow_isAccepted() throws {
        try validate(startDate: now)
    }

    // MARK: - Messages

    @Test func everyError_hasAMessage() {
        let errors: [ExerciseValidationError] = [.invalidCategory, .invalidDuration, .invalidIntensity, .startDateInFuture]
        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
        // Les bornes affichées viennent bien des constantes, pas de valeurs recopiées à la main
        #expect(ExerciseValidationError.invalidDuration.errorDescription == "La durée doit être comprise entre 1 et 1440 minutes.")
    }
}
