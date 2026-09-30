//
//  SleepHistoryViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class SleepHistoryViewModel: ObservableObject {
    @Published var sleepSessions = [Sleep]()
    /// Message à afficher à l'utilisateur si la récupération échoue, `nil` sinon.
    @Published var errorMessage: String?

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchSleepSessions()
    }

    private func fetchSleepSessions() {
        do {
            sleepSessions = try SleepRepository(viewContext: viewContext).getSleepSessions()
        } catch {
            errorMessage = "Impossible de charger l'historique de sommeil."
        }
    }
}
