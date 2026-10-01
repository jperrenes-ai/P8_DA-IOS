//
//  UserDataView.swift
//  Arista
//
//  Created by Vincent Saluzzo on 08/12/2023.
//

import SwiftUI

/// Écran « Utilisateur » : affiche le nom de l'utilisateur, en lecture seule.
struct UserDataView: View {
    /// La vue est propriétaire de son ViewModel : `@State` garantit qu'il est créé une seule
    /// fois et conservé tant que l'écran existe, même si SwiftUI redessine la vue parente.
    /// (Avec l'ancien `@ObservedObject`, rien ne garantissait cette conservation.)
    @State private var viewModel: UserDataViewModel

    /// J'ai gardé l'appel `UserDataView(viewModel: ...)` du PoC : l'`init` se contente de
    /// confier le ViewModel reçu au `@State`.
    init(viewModel: UserDataViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        // `NavigationStack` remplace `NavigationView`, dépréciée par Apple. Les trois onglets
        // l'utilisent maintenant, avec un grand titre : c'est ce qui les rend cohérents.
        NavigationStack {
            VStack(spacing: 16) {
                avatar

                Text("Bonjour")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("\(viewModel.firstName) \(viewModel.lastName)")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
            }
            .padding()
            // Le contenu est centré dans tout l'espace disponible.
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Utilisateur")
        }
        // Le PoC avait un « Hello » en anglais et une animation `repeatForever` basée sur
        // `UUID()` (une valeur différente à chaque rendu) : je l'ai retirée au profit d'une
        // présentation sobre, en français, qui suit le style des deux autres écrans.
        .errorAlert(message: $viewModel.errorMessage)
    }

    /// Pastille ronde avec les initiales, faute de photo de profil dans le modèle.
    private var avatar: some View {
        Text(initials)
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .frame(width: 110, height: 110)
            .background(Circle().fill(.tint))
    }

    /// « Charlotte Razoul » → « CR ». Si le nom n'est pas chargé, j'affiche « ? ».
    private var initials: String {
        let letters = [viewModel.firstName.first, viewModel.lastName.first].compactMap { $0 }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }
}

#Preview {
    // `preview` est une base en mémoire déjà remplie par `DefaultData`.
    UserDataView(viewModel: UserDataViewModel(context: PersistenceController.preview.container.viewContext))
}
