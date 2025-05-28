//
//  PartySearchView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 5/13/25.
//

import SwiftUI

struct StylishSearchBar: View {
    @ObservedObject var viewModel: PartySearchViewModel
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading){
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius:8, x:0, y:2)
                .frame(height:45)
            HStack(spacing:12){
                Image(systemName: "magnifyingglass")
                    .foregroundColor(
                        .blue
                    ) // change color based on focus state
                    .offset(x: isSearchFieldFocused ? 0 : -5)
                    .opacity(isSearchFieldFocused ? 1 : 0.8)
                    .animation(.spring(response: 0.4), value: isSearchFieldFocused)
                TextField("", text: $viewModel.searchText, prompt: Text("Type to search party...").foregroundColor(.gray))
                    .focused($isSearchFieldFocused)
                    .foregroundColor(.primary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onSubmit {
                        // call api
                    }
                    .overlay(
                        HStack{
                            Spacer()
                            if !viewModel.searchText.isEmpty{
                                Button {
                                    viewModel.searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                        .transition(.opacity.combined(with: .scale))
                                }
                            }
                        }
                    )
            }
            .padding(.horizontal, 20)
        }
        .padding(.horizontal)
        .onTapGesture{ isSearchFieldFocused = true }
    }
}

struct SuggestionRow: View {
    let host: Host
    let authUser: AuthUser
    @ObservedObject var viewModel: PartySearchViewModel
    @Binding var showJoinPartyView: Bool
    var onPartyJoined: () -> Void

    var body: some View {
        Text(host.party_code)
            .padding(.vertical, 5)
            .contentShape(Rectangle()) // <- This expands the tappable area
            .onTapGesture {
                print("trying to add " + authUser.username)
                viewModel.addGuest(
                    authUser: authUser,
                    guestName: "David Kaufman", // should eventually be dynamic
                    partyCode: host.party_code,
                    atParty: 1
                ) {
                    showJoinPartyView.toggle()
                    onPartyJoined()
                    print("Joined party successfully.")
                }
            }
    }
}


struct PartySearchView: View{
    let authUser: AuthUser
    @Binding var showJoinPartyView: Bool
    var onPartyJoined: () -> Void
    @StateObject var viewModel: PartySearchViewModel
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View{
        ZStack{
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.98, green: 0.87, blue: 0.87),
                Color(red: 0.87, green: 0.93, blue: 0.96),
                Color(red: 0.91, green: 0.89, blue: 0.96)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 15){
                Text("Join Party")
                StylishSearchBar(viewModel: viewModel)
                if !viewModel.suggestions.isEmpty {
                    List(viewModel.suggestions) { result in
                        SuggestionRow(
                            host: result,
                            authUser: authUser,
                            viewModel: viewModel,
                            showJoinPartyView: $showJoinPartyView,
                            onPartyJoined: onPartyJoined
                        )
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .transition(.opacity)
                } else {
                    Spacer()
                    Text("Search Results")
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding()
            .onTapGesture {
                isSearchFieldFocused = false
            }
            .animation(.easeInOut, value: viewModel.suggestions)
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView("Joining party...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        let previewVM = PartySearchViewModel(allHosts: [
//            Host(username: "Alice", party_name: "Beach Bash", party_code: "BEACH01", invite_only: 0, cognito_username: UUID()),
//            Host(username: "Bob", party_name: "Mountain Meetup", party_code: "MNTN22", invite_only: 1, cognito_username: UUID()),
//            Host(username: "Cathy", party_name: "City Lights", party_code: "CITY99", invite_only: 0, cognito_username: UUID())
//        ])
//        
//        PartySearchView(viewModel: previewVM)
//    }
//}
