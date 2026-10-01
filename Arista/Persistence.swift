//
//  Persistence.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import CoreData

/// Prépare la pile CoreData : le modèle `Arista.xcdatamodeld`, le fichier de base, et le
/// contexte (`viewContext`) par lequel passent toutes les lectures et écritures.
struct PersistenceController {
    /// L'instance utilisée par l'application, avec une base enregistrée sur l'appareil.
    /// C'est elle qui garantit que les données survivent au redémarrage de l'app.
    static let shared = PersistenceController()

    /// Contrôleur en mémoire alimenté par les données par défaut, destiné aux previews SwiftUI.
    ///
    /// Je remplis la base explicitement ici, et non dans `init`, pour que les tests puissent
    /// continuer à construire un contrôleur en mémoire réellement vide (voir plus bas).
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

    /// - Parameter inMemory: `true` pour une base temporaire qui disparaît à la fin du
    ///   processus. C'est ce qu'utilisent les tests, pour partir à chaque fois d'une base
    ///   vierge et obtenir des résultats prévisibles.
    init(inMemory: Bool = false) {
        // "Arista" est le nom du fichier `Arista.xcdatamodeld`.
        container = NSPersistentContainer(name: "Arista")
        if inMemory {
            // Faire pointer la base vers `/dev/null` revient à ne rien écrire sur le disque :
            // tout reste en mémoire.
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Code d'origine du template Xcode, que j'ai gardé : si la base ne peut même pas
                // être ouverte (disque plein, modèle incompatible…), l'app ne peut pas fonctionner.
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

        // Les données par défaut ne sont insérées que dans la base enregistrée sur l'appareil.
        // Sans ce `if`, les tests recevraient une base contenant déjà Charlotte et 5 nuits, et
        // un test comme « quand la base est vide, la liste est vide » échouerait.
        if !inMemory {
            do {
                try DefaultData(viewContext: container.viewContext).apply()
            } catch {
                // Le corrigé utilise `try!`, qui ferait planter l'app au lancement en cas
                // d'échec. Ici, l'app démarre quand même (les écrans afficheront « aucun
                // utilisateur »), et `assertionFailure` me prévient pendant le développement.
                assertionFailure("Insertion des données par défaut impossible : \(error)")
            }
        }
    }
}
