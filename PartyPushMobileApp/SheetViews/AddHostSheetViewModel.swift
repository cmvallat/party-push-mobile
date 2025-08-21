//
//  AddHostViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/26/25.
//

import Foundation

@MainActor
class AddHostSheetViewModel: ObservableObject {
    @Published var partyName = ""
    @Published var partyCode = ""
    @Published var desc = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func addHost(authUser: AuthUser, onSuccess: @escaping () -> Void) {
        guard !partyName.isEmpty, !partyCode.isEmpty else {
            errorMessage = "Please fill out party name and code."
            return
        }
        errorMessage = nil
        
        isLoading = true
        APIService.addHost(
            authUser: authUser,
            partyName: partyName,
            partyCode: partyCode,
            inviteOnly: 0,
            description: desc
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    Task { [weak self] in
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        await MainActor.run {
                            self?.isLoading = false
                            onSuccess()
                        }
                    }
                case .failure(let error):
                    self?.isLoading = false
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
