//
//  AddFoodViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/25/25.
//

import Foundation

class AddFoodViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var itemName = ""
    
//    Code for if we want to add a "Adding Food Item..." loading view
//    @Published var isLoading: Bool = false

//    func addFood(
//            authUser: AuthUser,
//            partyCode: String,
//            completion: @escaping (String) -> Void
//        ) {
//        isLoading = true
//        let dispatchGroup = DispatchGroup()
//
//        dispatchGroup.enter()
//        APIService.addFoodItem(
//            authUser: authUser,
//            itemName: itemName,
//            partyCode: partyCode,
//            status: "full",
//            completion: completion)
//            DispatchQueue.main.async {
//                dispatchGroup.leave()
//            }
//
//        dispatchGroup.notify(queue: .main) {
//            self.isLoading = false
//        }
//    }
    
    func addFood(
        authUser: AuthUser,
        partyCode: String,
        completion: @escaping (String) -> Void
    ) {
        guard !itemName.isEmpty, !partyCode.isEmpty else {
            errorMessage = "Please fill out itemName."
            return
        }
        errorMessage = nil
        
        APIService.addFoodItem(
            authUser: authUser,
            itemName: itemName,
            partyCode: partyCode,
            // default to full
            status: "full",
            completion: completion
        )
    }
}
