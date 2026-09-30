//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    /// Contrôleur en mémoire alimenté par les données par défaut, destiné aux previews SwiftUI.
    ///
    /// L'amorçage est fait explicitement ici, et non dans `init`, pour que les tests
    /// puissent continuer à construire un contrôleur en mémoire réellement vide.
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        do {
            try DefaultData(viewContext: result.container.viewContext).apply()
        } catch {
            assertionFailure("Préparation des données de preview impossible : \(error)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Arista")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true

        // Les données par défaut ne sont insérées que dans le store sur disque : les tests
        // construisent un contrôleur en mémoire et doivent partir d'une base vierge pour
        // rester prédictibles.
        if !inMemory {
            do {
                try DefaultData(viewContext: container.viewContext).apply()
            } catch {
                // Un échec ici laisse l'application sans utilisateur : l'interface le signalera.
                // On le rend bruyant en développement sans faire crasher l'app en production.
                assertionFailure("Insertion des données par défaut impossible : \(error)")
            }
        }
    }
}
