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

    @State private var showAddPartyView = false
    @State private var showJoinPartyView = false
    let authUser: AuthUser

    var body: some View {
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
    } // End of body
} // End of view

//#Preview {
//    UserManagementPage(authUser: AuthUser())
//}
