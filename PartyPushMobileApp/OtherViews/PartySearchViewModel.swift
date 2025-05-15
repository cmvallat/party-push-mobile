//
//  PartySearchViewModel.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 5/14/25.
//

import SwiftUI
import Combine

class PartySearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var suggestions: [Host] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSearchListener()
    }

    private func setupSearchListener() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task {
                    await self?.fetchSuggestions(for: query)
                }
            }
            .store(in: &cancellables)
    }

    func fetchSuggestions(for query: String) async {
        guard !query.isEmpty else {
            DispatchQueue.main.async {
                self.suggestions = []
            }
            return
        }

        guard let url = URL(string: "https://1bjg3dgpde.execute-api.us-east-1.amazonaws.com/Prod/hello?query=\(query)") else {
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let partyCodes = try JSONDecoder().decode(APIResponse<Host>.self, from: data)
            DispatchQueue.main.async {
                self.suggestions = partyCodes.data ?? []
            }
        } catch {
            print("Error fetching suggestions: \(error)")
            DispatchQueue.main.async {
                self.suggestions = []
            }
        }
    }
}

// Debugging with live preview and mock data:

//import SwiftUI
//import Combine
//
// Mock data:
//let mockHosts: [Host] = [
//    Host(username: "Alice", party_name: "Beach Bash", party_code: "BEACH01", invite_only: 0, cognito_username: UUID()),
//    Host(username: "Bob", party_name: "Mountain Meetup", party_code: "MNTN22", invite_only: 1, cognito_username: UUID()),
//    Host(username: "Cathy", party_name: "City Lights", party_code: "CITY99", invite_only: 0, cognito_username: UUID())
//]
//
//class PartySearchViewModel: ObservableObject {
//    @Published var searchText: String = ""
//    @Published var suggestions: [Host] = []
//    
//    private var allHosts: [Host]
//    private var cancellables = Set<AnyCancellable>()
//
//    init(allHosts: [Host] = mockHosts) {
//        self.allHosts = allHosts
//        setupSearchListener()
//    }
//
//    private func setupSearchListener() {
////        print("setup")
//        $searchText
//            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
//            .removeDuplicates()
//            .sink { [weak self] query in
////                print("Search query: \(query)")  // Debug print
//                self?.filterSuggestions(for: query)
//            }
//            .store(in: &cancellables)
//    }
//
//    private func filterSuggestions(for query: String) {
//        guard !query.isEmpty else {
//            self.suggestions = []
//            return
//        }
//        
////        print("Hosts count: \(allHosts.count)")
//        self.suggestions = allHosts.filter {
//            $0.party_code.localizedCaseInsensitiveContains(query) ||
//            $0.party_name.localizedCaseInsensitiveContains(query)
//        }
//    }
//}
