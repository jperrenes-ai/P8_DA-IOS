//
//  ErrorAlert.swift
//  Arista
//

import SwiftUI

extension View {
    /// Affiche une alerte tant que `message` n'est pas `nil`, et le remet à `nil` à la fermeture.
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
