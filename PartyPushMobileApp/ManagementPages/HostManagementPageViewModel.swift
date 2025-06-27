//
//  HostManagementPageViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/22/25.
//

import Foundation

class HostManagementViewModel: ObservableObject {
    @Published var foods = [Food]()
    @Published var guests = [Guest]()
    @Published var reportFoodResponse = ""
    @Published var isLoading: Bool = false

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

           group.enter()
           APIService.getGuestList(authUser: authUser, host: host) { [weak self] guests in
               DispatchQueue.main.async {
                   self?.guests = guests
                   group.leave()
               }
           }

           group.notify(queue: .main) {
               self.isLoading = false
           }
       }

    func deleteFoodItem(authUser: AuthUser, host: Host, itemName: String, completion: @escaping () -> Void) {
        APIService.deleteFoodItem(authUser: authUser, host: host, itemName: itemName) { response in
            DispatchQueue.main.async {
                if response.lowercased().contains("success") {
                    completion()
                } else {
                    // Handle error as needed
                    print("Failed to delete food item")
                }
            }
        }
    }


    func deleteGuest(authUser: AuthUser, host: Host, guest: Guest) {
        APIService.deleteGuest(authUser: authUser, party_code: host.party_code, username: guest.username, isHost: "true"){response in
            DispatchQueue.main.async{
                if(response == "Guest deleted successfully"){
                    print("removed guest successfully")
                }
            }
        }
    }
    
    func endParty(authUser: AuthUser, party_code: String, completion: @escaping (Bool) -> Void) {
        APIService.endParty(authUser: authUser, party_code: party_code) { response in
            DispatchQueue.main.async{
                completion(response == "Party ended successfully")
            }
        }
    }

    func reportFood(authUser: AuthUser, itemName: String, partyCode: String, status: String, completion: @escaping (Bool) -> Void) {
        APIService.reportFood(authUser: authUser, itemName: itemName, partyCode: partyCode, status: status, isHost: true) { [weak self] response in
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
