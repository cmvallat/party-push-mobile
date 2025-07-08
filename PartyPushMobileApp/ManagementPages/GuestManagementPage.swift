import SwiftUI

struct GuestManagementPage: View {
    var host: Host
    let authUser: AuthUser
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = GuestManagementViewModel()
    @State private var pollingTimer: Timer? = nil
    @State private var showGuestPopover: Bool = false
    @State private var showAddFoodView = false
    @State private var showLeavePartyConfirmation = false
    @State private var x = false
    @State private var showEndedPartyAlert = false
    @State private var showKickedPartyAlert = false
    @State private var showLeftPartyAlertScreen = false
    @State private var showDeleteGuestFailureAlert = false

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(host.party_name)
                    .font(.title)

                HStack {
                    Text("party code: \(host.party_code)")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                Text("About the Party")
                    .font(.title2)
                    .padding(.bottom, 10)

                Text((host.description ?? "No description currently"))
                    .font(.subheadline)

                Divider()

                List {
                    foodSection
                    HStack {
                        Spacer()
                        Button(action: {
                            showLeavePartyConfirmation = true
                        }) {
                            Text("Leave party")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .alert("Are you sure you want to leave this party?", isPresented: $showLeavePartyConfirmation) {
                    Button("Leave", role: .destructive) {
                        viewModel.deleteGuest(
                            authUser: authUser,
                            party_code: host.party_code,
                            username: authUser.username
                        ){
                            showLeftPartyAlertScreen = true
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .padding()

            Spacer()
        }
        .background(AppBackground())
        .overlay(
            Group {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView("Loading party details...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                    }
                }
            }
        )
        .sheet(isPresented: $showAddFoodView) {
            AddFoodSheet(
                host: host,
                authUser: authUser,
                showAddFoodView: $showAddFoodView,
                onFoodAdded: {
                    viewModel.refresh(authUser: authUser, host: host)
                }
            )
        }
        .refreshable {
            viewModel.refresh(authUser: authUser, host: host)
        }
        .onAppear {
            viewModel.refresh(authUser: authUser, host: host)
            startPollingPartyStatus()
            startPollingGuestStatus()
        }
        .onChange(of: appState.endedPartyCode, initial: true) { _, endedCode in
            if endedCode == host.party_code {
                showEndedPartyAlert = true
            }
        }
        .onChange(of: appState.atPartyState, initial: false) { oldState, newState in
//            if kickedUsername == authUser.username {
//                showKickedPartyAlert = true
//            }
            switch newState {
                case .left:
                    showLeftPartyAlertScreen = true
                case .removed:
                    showKickedPartyAlert = true
                case .active:
                    appState.atPartyState = .active
            }
        }
        .onChange(of: viewModel.deleteGuestFailed) { failed in
            if failed {
                showDeleteGuestFailureAlert = true
                viewModel.deleteGuestFailed = false
            }
        }
        .onDisappear {
            pollingTimer?.invalidate()
            pollingTimer = nil
        }
        .alert("The Host has ended this party.", isPresented: $showEndedPartyAlert) {
            Button("OK") {
                appState.needToRefresh = true
                dismiss()
            }
        }
        .alert("You have successfully left this party.", isPresented: $showLeftPartyAlertScreen) {
            Button("OK") {
                appState.needToRefresh = true
                dismiss()
            }
        }
        .alert("The host has removed you from this party.", isPresented: $showKickedPartyAlert) {
            Button("OK") {
                appState.needToRefresh = true
                dismiss()
            }
        }
        .alert("Could not leave the party. Please try again.", isPresented: $showDeleteGuestFailureAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    private var foodSection: some View {
        Section {
            if viewModel.foods.isEmpty {
                VStack {
                    Text("No foods at the party right now. Check back later or swipe down to refresh.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.foods) { row in
                    HStack {
                        // display a helpful icon based on the food item's current status
                        row.statusIcon.foregroundStyle(row.statusColor)
                        
                        Text(row.item_name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    viewModel.optimisticallyReportFoodStatus(authUser: authUser, host: host, itemName: row.item_name, newStatus: "out")
                                } label: {
                                    Label("Out", systemImage: "exclamationmark.shield.fill")
                                }
                                .tint(.red)

                                Button {
                                    viewModel.optimisticallyReportFoodStatus(authUser: authUser, host: host, itemName: row.item_name, newStatus: "low")
                                } label: {
                                    Label("Low", systemImage: "exclamationmark.triangle.fill")
                                }
                                .tint(.yellow)
                            }
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 3)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        } header: {
            Text("Food and Drinks").font(.headline)
        }
        .headerProminence(.increased)
    }

    
    private var emptyOverlay: some View {
        Group {
            if viewModel.foods.isEmpty{
                Text("No foods at the party right now. Check back later or swipe down to refresh.")
                    .padding()
            }
        }
    }
    
    private func startPollingPartyStatus() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            APIService.checkPartyStatus(party_code: host.party_code, authUser: authUser) { stillActive in
                if !stillActive {
                    DispatchQueue.main.async {
                        appState.endedPartyCode = host.party_code
                    }
                }
            }
        }
    }
    
    private func startPollingGuestStatus() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            APIService.checkGuestStatus(party_code: host.party_code, authUser: authUser) { guestStatus in
                DispatchQueue.main.async {
                    switch guestStatus {
                    case "left":
                        appState.atPartyState = .left
                    case "DNE":
                        appState.atPartyState = .removed
                    case "active":
                        appState.atPartyState = .active
                    default:
                        // TODO: throw an error or break or something (handle it)
                        print("non-recognized guest status")
                    }
                }
            }
        }
    }
    
}
