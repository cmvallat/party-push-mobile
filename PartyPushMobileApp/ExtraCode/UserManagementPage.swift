//
//  UserManagementPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import SwiftUI
import TipKit
import AVKit
import WebKit

struct GIFView: UIViewRepresentable {
    let gifName: String
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.isOpaque = false
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let url = URL(fileURLWithPath: path)
            let data = try? Data(contentsOf: url)
            webView.load(data!, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
        }
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// Enum representing each step in the onboarding tip sequence
enum TipStep: Int, CaseIterable {
    case joinParty, addHost, swipeAction // Add more cases as needed
}

// View for displaying the onboarding tip content based on the current step
struct OnboardingTipContent: View {
    let tipStep: TipStep
    let isLast: Bool
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            switch tipStep {
            case .joinParty:
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.largeTitle)
                    Text("Join Party")
                        .font(.title2).bold()
                    Text("Tap the magnifying glass at the top right of the page to join a party using a code or search.")
                        .font(.body)
                }
            case .addHost:
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                    Text("New Party")
                        .font(.title2).bold()
                    Text("Tap the plus button at the top right of the page to create and host a new party.")
                        .font(.body)
                }
            case .swipeAction:
                VStack(spacing: 8) {
                    GIFView(gifName: "reportFoodTipEditedGif")
                        .frame(height: 140)
                        .cornerRadius(12)
                    
                    Text("Report Food")
                        .font(.title2).bold()
                    Text("Swipe left to report food as a new status, either as a Host or Guest.")
                        .font(.body)
                }
            }

            if isLast {
                Button("Got it!") {
                    onDismiss()
                }
                .padding(.top, 10)
            }
        }
        .padding(30)
        .frame(maxWidth: 350)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .shadow(radius: 10)
    }
}

struct OnboardingTipPager: View {
    @Binding var isPresented: Bool
    @State private var selectedPage = 0
    let steps = TipStep.allCases

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPage) {
                ForEach(steps.indices, id: \.self) { idx in
                    OnboardingTipContent(
                        tipStep: steps[idx],
                        isLast: idx == steps.count - 1,
                        onDismiss: { isPresented = false }
                    )
                    .tag(idx)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(maxWidth: 350, maxHeight: 350)
        }
    }
}

struct DeepLinkPartyCode: Identifiable, Equatable {
    let code: String
    var id: String { code }
}

struct UserManagementPage: View {
    @StateObject var viewModel = UserManagementViewModel()
    @StateObject private var searchViewModel = PartySearchViewModel()

    @State private var showAddPartyView = false
    @State private var showJoinPartyView = false
    @State private var showLogoutConfirmation = false
    let authUser: AuthUser
    @ObservedObject var appState: AppState
    @EnvironmentObject var sessionManager: SessionManager

    @State private var showOnboardingTips = false
    
    @State var tipGroup = TipGroup(.ordered){
        AddHostTip()
        JoinPartyTip()
        HelpTip()
    }
    
    @State private var pendingDeepLinkPartyCode: DeepLinkPartyCode? = nil

    var body: some View {
        VStack {
            NavigationSplitView {
                mainListView
                    .navigationTitle("Your parties")
                    .toolbar {
                        ToolbarItem {
                            Button(action: {
                                showOnboardingTips.toggle()
                                (tipGroup.currentTip)?.invalidate(reason: .actionPerformed)
                            }) {
                                Label("Help", systemImage: "questionmark.circle.fill")
                            }
                            .tint(Color.green)
                            .popoverTip(tipGroup.currentTip as? HelpTip)
                        }
                        ToolbarItem {
                            Button(action: {
                                showJoinPartyView.toggle()
                                (tipGroup.currentTip)?.invalidate(reason: .actionPerformed)
                            }) {
                                Label("Join party", systemImage: "magnifyingglass.circle.fill")
                            }
                            .tint(Color.green)
                            .popoverTip(tipGroup.currentTip as? JoinPartyTip)
                        }
                        ToolbarItem {
                            Button(action: {
                                showAddPartyView.toggle()
                                (tipGroup.currentTip)?.invalidate(reason: .actionPerformed)
                            }) {
                                Label("New party", systemImage: "plus.circle.fill")
                            }
                            .tint(Color.green)
                            .popoverTip(tipGroup.currentTip as? AddHostTip)
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showLogoutConfirmation = true
                            }) {
                                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right.fill")
                            }
                            .tint(Color.red)
                            .alert("Are you sure you want to log out?", isPresented: $showLogoutConfirmation) {
                                Button("Log Out", role: .destructive) {
                                    sessionManager.logout(authUser: authUser)
                                    viewModel.hosting = []
                                    viewModel.attending = []
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                        }
                    }
            } detail: {
                Text("Your parties").font(.title)
            }
            .overlay(emptyOverlay)
            .overlay(loadingOverlay)
        }
        // Onboarding tips overlay to show paged guidance with swipe and dots
        .overlay(walkthroughOverlay)
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
            authUser.loadTokensFromKeychain()
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
        .onOpenURL { url in
            print("SwiftUI onOpenURL called with: \(url)")
            if let code = extractPartyCode(from: url) {
                pendingDeepLinkPartyCode = DeepLinkPartyCode(code: code)
            }
        }
        // TODO: UNCOMMENT FOR UNIVERSAL LINKING WITH NEW JOINPARTYSHEET
//        .sheet(item: $pendingDeepLinkPartyCode) { code in
//            JoinPartySheet(partyCode: code.code)
//        }
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
//                .listRowBackground(Color.pink.opacity(0.1))
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
//                .listRowBackground(Color.blue.opacity(0.1))
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
    
    private var walkthroughOverlay: some View {
        Group {
            if showOnboardingTips {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack {
                    Spacer(minLength: 100)
                    OnboardingTipPager(isPresented: $showOnboardingTips)
                    Spacer()
                }
            }
        }
    }
    
    func extractPartyCode(from url: URL) -> String? {
        let components = url.pathComponents
        if components.count >= 3 && components[1] == "join-party" {
            return components[2]
        }
        return nil
    }

//    private var toolbarButtons: some View {
//
//        return HStack {
//            Button(action: {
//                showOnboardingTips.toggle()
//            }) {
//                Label("Help", systemImage: "questionmark.circle.fill")
//            }
//            .tint(Color.green)
//            
//            let tipGroup = TipGroup(.ordered) {
//                AddHostTip()
//                JoinPartyTip()
//            }
//            
//            Button(action: {
//                showJoinPartyView.toggle()
//            }) {
//                Label("Join party", systemImage: "magnifyingglass.circle.fill")
//            }
//            .tint(Color.green)
//            
//            Button(action: {
//                showAddPartyView.toggle()
//            }) {
//                Label("New party", systemImage: "plus.circle.fill")
//            }
//            .tint(Color.green)
//            .popoverTip(tipGroup)
//        }
//    }
} // End of struct

// TODO: UNCOMMENT FOR UNIVERSAL LINK WITH NEW JOINPARTYSHEET
//struct JoinPartySheet: View, Identifiable {
//    let partyCode: String
//    var id: String { partyCode }
//    var body: some View {
//        VStack {
//            Text("Join party with code: \(partyCode)")
//            // Add UI to prompt for guest name, etc.
//        }
//        .padding()
//    }
//}

//#Preview {
//    UserManagementPage(authUser: AuthUser())
//}
