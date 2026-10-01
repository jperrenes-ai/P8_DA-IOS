//
//  Components.swift
//  Arista
//

import SwiftUI

// Petits composants visuels partagés par plusieurs écrans.
//
// L'énoncé relève que « les trois écrans n'ont pas forcément de cohérence visuelle ».
// Avant, l'intensité d'un exercice était un simple point de couleur et la qualité du sommeil
// un cercle avec un chiffre : deux façons différentes de représenter une note sur 10.
// J'ai regroupé ici un indicateur commun, ainsi que le formatage des durées, pour que
// les écrans Exercices et Sommeil se ressemblent.

/// Note sur 10 affichée dans un cercle coloré.
///
/// C'est la brique de base de `IntensityIndicator` et `QualityIndicator` : seule la couleur
/// change, selon que « 10 » est une bonne nouvelle (sommeil) ou un gros effort (exercice).
struct ScoreIndicator: View {
    let value: Int
    let color: Color

    var body: some View {
        Text("\(value)")
            .font(.subheadline.bold())
            .monospacedDigit()
            .foregroundStyle(color)
            // Même largeur (36) que la colonne d'icônes de la liste des exercices : comme ça,
            // le texte commence exactement au même endroit sur les écrans Exercices et Sommeil.
            .frame(width: 36, height: 36)
            .overlay {
                Circle().stroke(color, lineWidth: 3)
            }
    }
}

/// Intensité d'un exercice : vert pour un effort léger, rouge pour un effort intense.
struct IntensityIndicator: View {
    let intensity: Int

    var body: some View {
        ScoreIndicator(value: intensity, color: Self.color(for: intensity))
    }

    /// Je garde les mêmes seuils que dans le PoC d'origine (0-3, 4-6, 7-10).
    static func color(for intensity: Int) -> Color {
        switch intensity {
        case 0...3: return .green
        case 4...6: return .orange
        case 7...10: return .red
        default: return .gray
        }
    }
}

/// Qualité d'une nuit : c'est l'inverse de l'intensité, une note haute est en vert.
struct QualityIndicator: View {
    let quality: Int

    var body: some View {
        ScoreIndicator(value: quality, color: Self.color(for: quality))
    }

    static func color(for quality: Int) -> Color {
        switch quality {
        case 7...10: return .green
        case 4...6: return .orange
        case 0...3: return .red
        default: return .gray
        }
    }
}

/// Formate une durée exprimée en minutes, par exemple « 7 h et 50 min » ou « 45 min ».
///
/// Avant, l'écran Sommeil faisait `duration / 60` et affichait « heures » : on perdait les
/// minutes (7 h 50 devenait « 7 heures ») et on obtenait « 1 heures » au singulier.
/// Le `Duration.formatted` d'Apple gère l'arrondi, le pluriel et la langue.
///
/// La langue suit celle de l'application : j'ai déclaré le français comme langue de
/// développement du projet (`developmentRegion = fr`), sinon, sur un iPhone réglé en anglais,
/// on obtenait « 7 hrs, 50 min » au milieu d'une interface en français.
func formattedDuration(minutes: Int64) -> String {
    Duration.seconds(minutes * 60)
        .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
}

#Preview {
    VStack(spacing: 16) {
        HStack { IntensityIndicator(intensity: 2); IntensityIndicator(intensity: 5); IntensityIndicator(intensity: 9) }
        HStack { QualityIndicator(quality: 2); QualityIndicator(quality: 5); QualityIndicator(quality: 9) }
        Text(formattedDuration(minutes: 470))
    }
}
