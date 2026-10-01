//
//  ErrorAlert.swift
//  Arista
//

import SwiftUI

// Les quatre ViewModels exposent tous un `errorMessage: String?`, et les quatre vues doivent
// afficher une alerte quand il est renseigné. Plutôt que de recopier le même code d'alerte
// dans chaque vue, j'ai écrit ce modificateur une fois pour toutes :
//
//     .errorAlert(message: $viewModel.errorMessage)

extension View {
    /// Affiche une alerte tant que `message` n'est pas `nil`, et le remet à `nil` à la fermeture.
    ///
    /// L'API `alert` de SwiftUI attend un `Binding<Bool>` (« l'alerte est-elle visible ? »).
    /// Je le fabrique à partir du message :
    /// - en lecture, l'alerte est visible si un message existe ;
    /// - en écriture, quand l'utilisateur ferme l'alerte, SwiftUI passe la valeur à `false`,
    ///   et j'efface alors le message pour que l'alerte ne réapparaisse pas.
    func errorAlert(message: Binding<String?>) -> some View {
        alert(
            "Erreur",
            isPresented: Binding(
                get: { message.wrappedValue != nil },
                set: { if !$0 { message.wrappedValue = nil } }
            ),
            presenting: message.wrappedValue
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { text in
            Text(text)
        }
    }
}
