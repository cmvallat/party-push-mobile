//
//  AddFoodViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/25/25.
//

import Foundation

class AddFoodViewModel: ObservableObject {
    // Code for if we want to add a "Adding Food Item..." loading view
//    @Published var isLoading: Bool = false

//    func addFood(
//            authUser: AuthUser,
//            itemName: String,
//            partyCode: String,
//            status: String,
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
//            status: status,
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
        itemName: String,
        partyCode: String,
        status: String,
        completion: @escaping (String) -> Void
    ) {
        APIService.addFoodItem(
            authUser: authUser,
            itemName: itemName,
            partyCode: partyCode,
            status: status,
            completion: completion
        )
    }
}
