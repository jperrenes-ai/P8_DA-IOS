//
//  UserDataViewModel.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import Foundation
import CoreData

class UserDataViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    /// Message à afficher à l'utilisateur si la récupération échoue, `nil` sinon.
    @Published var errorMessage: String?

    private var viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchUserData()
    }

    private func fetchUserData() {
        do {
            guard let user = try UserRepository(viewContext: viewContext).getUser() else {
                errorMessage = "Aucun utilisateur n'a été trouvé."
                return
            }
            firstName = user.firstName ?? ""
            lastName = user.lastName ?? ""
        } catch {
            errorMessage = "Impossible de charger les données utilisateur."
        }
    }
}
