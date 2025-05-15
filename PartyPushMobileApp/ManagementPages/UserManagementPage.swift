//
//  UserManagementPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import SwiftUI

struct UserManagementPage: View {
    @StateObject var viewModel = UserManagementViewModel()
    @StateObject private var searchViewModel = PartySearchViewModel()
//    @StateObject private var searchViewModel = PartySearchViewModel()

    @State private var showAddPartyView = false
    @State private var showJoinPartyView = false
    let authUser: AuthUser

    var body: some View {
        //        }
//        HStack {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.gray)
//            
//            TextField("Search party...", text: $searchViewModel.query)
//                .autocapitalization(.none)
//                .disableAutocorrection(true)
//            
//            if !searchViewModel.suggestions.isEmpty {
//                List(searchViewModel.suggestions, id: \.self) { party in
//                    Button(action: {
//                        // You can add logic to join party here
//                        print("Joining party: \(party.party_code)")
//                        // Example:
//                        // viewModel.joinParty(code: code)
//                    }) {
//                        Text(party.party_code)
//                    }
//                }
//                .listStyle(.plain)
//                .frame(height: 200)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 10)
//        .background(Color(.systemGray6))
//        .clipShape(Capsule())
//        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
//        .padding(.horizontal)
        
//        ZStack(alignment: .top) {
            VStack {
                NavigationSplitView {
                    List {
                        Section {
                            ForEach(viewModel.hosting) { host in
                                NavigationLink {
                                    HostManagementPage(host: host, authUser: authUser)
                                } label: {
                                    HostRow(host: host)
                                }
                            }
                            .listRowBackground(Color.pink.opacity(0.1))
                        } header: {
                            Text("Hosting").font(.headline)
                        }
                        .headerProminence(.increased)
                        
                        Section {
                            ForEach(viewModel.attending) { host in
                                NavigationLink {
                                    GuestManagementPage(host: host, authUser: authUser)
                                } label: {
                                    HostRow(host: host)
                                }
                            }
                            .listRowBackground(Color.blue.opacity(0.1))
                        } header: {
                            Text("Attending").font(.headline)
                        }
                        .headerProminence(.increased)
                    }
                    .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
                    .scrollContentBackground(.hidden)
                    .navigationTitle("Your parties")
                    //                .toolbar {
                    //                    HStack {
                    //                        Button(action: {
                    //                            showAddPartyView.toggle()
                    //                        }) {
                    //                            Label("Join party", systemImage: "magnifyingglass.circle.fill")
                    //                        }
                    //                        .tint(Color.green)
                    //
                    //                        Button(action: {
                    //                            showAddPartyView.toggle()
                    //                        }) {
                    //                            Label("New party", systemImage: "plus.circle.fill")
                    //                        }
                    //                        .tint(Color.green)
                    //                    }
                    //                }
//                    .toolbar {
//                        ToolbarItemGroup(placement: .navigationBarLeading) {
//                            HStack(spacing: 8) {
//                                HStack {
//                                    Image(systemName: "magnifyingglass")
//                                        .foregroundColor(.gray)
//                                    TextField("Search party...                                  ", text: $searchViewModel.query)
//                                        .autocapitalization(.none)
//                                        .disableAutocorrection(true)
//                                }
//                                .padding(.horizontal, 12)
//                                .padding(.vertical, 8)
//                                .background(Color(.systemGray6))
//                                .clipShape(Capsule())
//                                .frame(maxWidth: .infinity)
//
////                                Spacer(minLength: 8)
//
//                                Button(action: {
//                                    showAddPartyView.toggle()
//                                }) {
//                                    Image(systemName: "plus.circle.fill")
//                                        .foregroundColor(.green)
//                                        .imageScale(.large)
//                                }
//                            }
//                        }
//                    }
                    .toolbar {
                        HStack {
                            Button(action: {
                                showJoinPartyView.toggle()
                            }) {
                                Label("Join party", systemImage: "magnifyingglass.circle.fill")
                            }
                            .tint(Color.green)

                            Button(action: {
                                showAddPartyView.toggle()
                            }) {
                                Label("New party", systemImage: "plus.circle.fill")
                            }
                            .tint(Color.green)
                        }
                    }

                } detail: {
                    Text("Your parties")
                }
                // Overlay for showing no parties
                .overlay(
                    Group {
                        if viewModel.hosting.isEmpty && viewModel.attending.isEmpty {
                            Text("You aren't hosting or attending any parties right now. Try adding or joining a party and swiping down to refresh.")
                                .padding()
                        }
                    })
                // Loading overlay
                .overlay(
                    Group {
                        if viewModel.isLoading {
                            ZStack {
                                Color.black.opacity(0.3).ignoresSafeArea()
                                ProgressView("Loading parties...")
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 10)
                            }
                        }
                    }
                )
            } // End of VStack
            .sheet(isPresented: $showAddPartyView) {
                AddHostSheet(authUser: authUser, showAddPartyView: $showAddPartyView, onPartyAdded: {
                    viewModel.loadParties(authUser: authUser) // Trigger loadParties from the viewModel
                })
            }
            .sheet(isPresented: $showJoinPartyView) {
                PartySearchView(viewModel: searchViewModel)
            }
            .refreshable {
                viewModel.loadParties(authUser: authUser)
            }
            .onAppear {
                sendNotification(authUser: authUser, title: "Party Push", body: "Hi, welcome back to party push!")
                viewModel.loadParties(authUser: authUser)
            }
            
//            if !searchViewModel.suggestions.isEmpty && !searchViewModel.query.isEmpty {
//                VStack(spacing: 0) {
//                    ForEach(searchViewModel.suggestions, id: \.self) { party in
//                        Button(action: {
//                            // Trigger join logic
//                            print("Joining party: \(party.party_code)")
//                            print("username: \(authUser.username)")
//                            print("party_code: \(party.party_code)")
//                            print("cog username: \(authUser.cognito_username)")
//
//                            searchViewModel.addGuest(
//                                authUser: authUser,
//                                partyCode: party.party_code,
//                                guestName: "Chris V"
//                            ) {
//                                searchViewModel.query = ""
//                                viewModel.loadParties(authUser: authUser)
//                            }
//                        }) {
//                            Text(party.party_code)
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color.white)
//                        }
//                        Divider()
//                    }
//                }
//                .background(Color.white)
//                .cornerRadius(10)
//                .shadow(radius: 5)
//                .padding(.horizontal)
//                .padding(.top, 90) // Adjust height to place just below toolbar
//                .zIndex(1)
//            }
            
        //} // End of Zstack
        
//        if !searchViewModel.suggestions.isEmpty {
//            List(searchViewModel.suggestions, id: \.self) { party in
//                Button(action: {
//                    // You can add logic to join party here
//                    print("Joining party: \(party.party_code)")
//                    // Example:
//                    // viewModel.joinParty(code: code)
//                }) {
//                    Text(party.party_code)
//                }
//            }
//            .listStyle(.plain)
//            .frame(height: 200)
//        }
    } // End of body
} // End of view

//#Preview {
//    UserManagementPage(authUser: AuthUser())
//}
