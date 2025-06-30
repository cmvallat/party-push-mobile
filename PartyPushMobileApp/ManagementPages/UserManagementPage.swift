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
    @ObservedObject var appState: AppState


    var body: some View {
        VStack {
            NavigationSplitView {
                mainListView
                    .navigationTitle("Your parties")
                    .toolbar {
                        toolbarButtons
                    }
            } detail: {
                Text("Your parties").font(.title)
            }
            .overlay(emptyOverlay)
            .overlay(loadingOverlay)
        }
        .sheet(isPresented: $showAddPartyView) {
            AddHostSheet(authUser: authUser, showAddPartyView: $showAddPartyView) {
                viewModel.loadParties(authUser: authUser)
            }
        }
        .sheet(isPresented: $showJoinPartyView) {
            PartySearchView(
                authUser: authUser,
                showJoinPartyView: $showJoinPartyView,
                onPartyJoined: {
                    viewModel.loadParties(authUser: authUser)
                },
                viewModel: searchViewModel
            )
        }
        .refreshable {
            viewModel.loadParties(authUser: authUser)
        }
        .onAppear {
            sendNotification(authUser: authUser, title: "Party Push", body: "Hi, welcome back to party push!")
            viewModel.loadParties(authUser: authUser)
        }
        .onChange(of: appState.needToRefresh, initial: false) { _, refresh in
            if(refresh)
            {
                viewModel.loadParties(authUser: authUser)
                appState.endedPartyCode = nil
                appState.kickedGuestUsername = nil
                appState.needToRefresh = false
            }
        }
    }
    
private var mainListView: some View {
    List {
        Section {
            ForEach(viewModel.hosting) { host in
                NavigationLink {
                    HostManagementPage(host: host, authUser: authUser, appState: appState)
                } label: {
                    PartyRow(party_name: host.party_name, isHost: true)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(radius: 3)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
//            .listRowBackground(Color.pink.opacity(0.1))
        } header: {
            Text("Hosting").font(.title2)
        }
        .headerProminence(.increased)

        Section {
            ForEach(viewModel.attending) { host in
                NavigationLink {
                    GuestManagementPage(host: host, authUser: authUser, appState: appState)
                } label: {
                    PartyRow(party_name: host.party_name, isHost: false)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(radius: 3)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
//            .listRowBackground(Color.blue.opacity(0.1))
        } header: {
            Text("Attending").font(.title2)
        }
        .headerProminence(.increased)
    }
    .background(AppBackground())
    .scrollContentBackground(.hidden)
}

private var emptyOverlay: some View {
    Group {
        if viewModel.hosting.isEmpty && viewModel.attending.isEmpty {
            Text("You aren't hosting or attending any parties right now. Try adding or joining a party and swiping down to refresh.")
                .padding()
        }
    }
}

private var loadingOverlay: some View {
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
}

private var toolbarButtons: some View {
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
} // End of struct



//#Preview {
//    UserManagementPage(authUser: AuthUser())
//}
