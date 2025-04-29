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

// In case they are needed later:
    
//    func getFoodList(authUser: AuthUser, host: Host) {
//        APIService.getFoodList(authUser: authUser, host: host) { [weak self] foods in
//            DispatchQueue.main.async {
//                self?.foods = foods
//            }
//        }
//    }
//
//    func getGuestList(authUser: AuthUser, host: Host) {
//        APIService.getGuestList(authUser: authUser, host: host) { [weak self] guests in
//            DispatchQueue.main.async {
//                self?.guests = guests
//            }
//        }
//    }

    func deleteFoodItem(authUser: AuthUser, host: Host, itemName: String) {
        APIService.deleteFoodItem(authUser: authUser, host: host, itemName: itemName)
    }

    func deleteGuest(authUser: AuthUser, host: Host, guest: Guest) {
        APIService.deleteGuest(authUser: authUser, host: host, guest: guest)
    }

    func reportFood(authUser: AuthUser, itemName: String, partyCode: String, status: String) {
        APIService.reportFood(authUser: authUser, itemName: itemName, partyCode: partyCode, status: status) { [weak self] response in
            DispatchQueue.main.async {
                self?.reportFoodResponse = response
            }
        }
    }
}
