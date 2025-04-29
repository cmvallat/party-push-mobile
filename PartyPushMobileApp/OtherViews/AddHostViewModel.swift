//
//  AddHostViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/26/25.
//

import Foundation

@MainActor
class AddHostViewModel: ObservableObject {
    @Published var partyName = ""
    @Published var partyCode = ""
    @Published var inviteOnly = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    func addHost(authUser: AuthUser, onSuccess: @escaping () -> Void) {
        isLoading = true
        APIService.addHost(
            authUser: authUser,
            partyName: partyName,
            partyCode: partyCode,
            inviteOnly: inviteOnly ? 1 : 0
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    onSuccess()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
