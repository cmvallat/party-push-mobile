//
//  GuestManagementPageViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/26/25.
//


import Foundation

class GuestManagementViewModel: ObservableObject {
    @Published var foods = [Food]()
    @Published var reportFoodResponse = ""
    @Published var isLoading: Bool = false
    @Published var showLeftPartyAlert = false
    @Published var deleteGuestFailed = false


    func refresh(authUser: AuthUser, host: Host) {
           isLoading = true
           let group = DispatchGroup()

           group.enter()
           APIService.getFoodList(authUser: authUser, host: host) { [weak self] foods in
               DispatchQueue.main.async {
                   self?.foods = foods
                   group.leave()
               }
           }
        
           group.notify(queue: .main) {
               self.isLoading = false
           }
       }
    
    func deleteGuest(authUser: AuthUser, party_code: String, username: String, onSuccess: @escaping () -> Void) {
        APIService.deleteGuest(authUser: authUser, party_code: party_code, username: username, isHost: "false"){ response in
            DispatchQueue.main.async{
                if(response == "Guest deleted successfully")
                {
                    onSuccess()
                }
                else
                {
                    self.deleteGuestFailed = true
                }
            }
        }
    }

    func reportFood(authUser: AuthUser, itemName: String, partyCode: String, status: String, completion: @escaping (Bool) -> Void) {
        APIService.reportFood(authUser: authUser, itemName: itemName, partyCode: partyCode, status: status, isHost: false) { [weak self] response in
            DispatchQueue.main.async {
                self?.reportFoodResponse = response
                // If the server reply was successful
                completion(response.lowercased().contains("success"))
            }
        }
    }
    
    func updateFoodStatusLocally(itemName: String, newStatus: String) {
        if let index = foods.firstIndex(where: { $0.item_name == itemName }) {
            foods[index].status = newStatus
        }
    }
    
    func optimisticallyReportFoodStatus(authUser: AuthUser, host: Host, itemName: String, newStatus: String) {
        let oldStatus = foods.first(where: { $0.item_name == itemName })?.status ?? ""

        // update locally first
        updateFoodStatusLocally(itemName: itemName, newStatus: newStatus)

        // update in database
        reportFood(authUser: authUser, itemName: itemName, partyCode: host.party_code, status: newStatus) { [weak self] success in
            guard let self = self else { return }
            if !success {
                // roll back if failed
                self.updateFoodStatusLocally(itemName: itemName, newStatus: oldStatus)
            } else {
                // refresh to fully sync if success
//                self.refresh(authUser: authUser, host: host)
            }
        }
    }

}
