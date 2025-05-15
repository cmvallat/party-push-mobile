//
//  UserManagementPageViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/22/25.
//

import Foundation

class UserManagementViewModel: ObservableObject {
    @Published var hosting = [Host]()
    @Published var attending = [Host]()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
// In case they are needed later:
//    func getPartiesHosting(authUser: AuthUser) {
//           APIService.getPartiesHosting(authUser: authUser) { [weak self] hosts in
//               DispatchQueue.main.async {
//                   self?.hosting = hosts
//               }
//           }
//       }
//
//       func getPartiesAttending(authUser: AuthUser) {
//           APIService.getPartiesAttending(authUser: authUser) { [weak self] guests in
//               DispatchQueue.main.async {
//                   self?.attending = guests
//               }
//           }
//       }

       func loadParties(authUser: AuthUser) {
           isLoading = true
           let dispatchGroup = DispatchGroup()

           dispatchGroup.enter()
           APIService.getPartiesHosting(authUser: authUser) { [weak self] hosts in
               DispatchQueue.main.async {
                   self?.hosting = hosts
                   dispatchGroup.leave()
               }
           }

           dispatchGroup.enter()
           APIService.getPartiesAttending(authUser: authUser) { [weak self] guests in
               DispatchQueue.main.async {
                   self?.attending = guests
                   dispatchGroup.leave()
               }
           }

           dispatchGroup.notify(queue: .main) {
               self.isLoading = false
           }
       }
}
