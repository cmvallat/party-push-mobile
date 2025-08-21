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

// In case they are needed later:
    func getHost(completion: @escaping (Host?) -> Void) {
        APIService.getHost(party_code: self.partyCode) { [weak self] returnedHost in
               DispatchQueue.main.async {
                   if let host = returnedHost {
                       completion(host)
                   } else {
                       self?.errorMessage = "Party not found. Please check your party code."
                       completion(nil)
                   }
               }
           }
       }
    
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
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

