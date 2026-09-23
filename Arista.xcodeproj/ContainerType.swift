//
//  ContainerType.swift
//  Arista
//

import Foundation

/// Contenants proposés pour l'ajout rapide d'hydratation, correspondant à l'énumération
/// `TypeContenant` du diagramme de classes. La valeur brute est celle persistée dans
/// l'attribut `HydrationEntity.containerType` : ne jamais la modifier sans migration.
enum ContainerType: String, CaseIterable, Identifiable {
    case glass25cl = "Verre 25cl"
    case glass33cl = "Verre 33cl"
    case bottle50cl = "Bouteille 50cl"
    case bottle1L = "Bouteille 1L"

    var id: String { rawValue }

    /// Libellé destiné à l'affichage.
    var displayName: String { rawValue }

    /// Volume du contenant en centilitres, utilisé pour préremplir `HydrationEntity.quantity`.
    var volumeInCentiliters: Double {
        switch self {
        case .glass25cl: return 25
        case .glass33cl: return 33
        case .bottle50cl: return 50
        case .bottle1L: return 100
        }
    }
}
