//
//  JoinPartySheetViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 7/7/25.
//

import SwiftUI

class JoinPartySheetViewModel: ObservableObject {
    @Published var guestName = ""
    @Published var partyCode = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func addGuest(authUser: AuthUser, onSuccess: @escaping () -> Void) {
        guard !guestName.isEmpty, !partyCode.isEmpty else {
                errorMessage = "Please fill out party name and code."
                return
            }
        errorMessage = nil
        
        isLoading = true
        APIService.addGuest(
            authUser: authUser,
            guestName: guestName,
            partyCode: partyCode,
            atParty: 1
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

