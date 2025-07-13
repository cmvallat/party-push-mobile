import SwiftUI

struct GuestManagementPage: View {
    var host: Host
    let authUser: AuthUser
    @ObservedObject var appState: AppState

    @StateObject private var viewModel = GuestManagementViewModel()
    @State private var pollingTimer: Timer? = nil
    @State private var showGuestPopover: Bool = false
    @State private var showAddFoodView = false
    @State private var showLeavePartyConfirmation = false
    @State private var showEndedPartyAlert = false
    @State private var showKickedPartyAlert = false
    @State private var showLeftPartyAlertScreen = false
    @State private var showDeleteGuestFailureAlert = false
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            LinearGradient(colors: Palette.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            //ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(host.party_name)
                            .font(.largeTitle.bold())
                            .foregroundColor(Palette.deepTextColor)
                        Text("Party Code: \(host.party_code)")
                            .font(.headline)
                            .foregroundColor(Palette.deepTextColor.opacity(0.7))
                    }
                    .padding(.top, 32)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("About the Party")
                            .font(.title3.bold())
                            .foregroundColor(Palette.deepTextColor)
                        Text(host.description ?? "No description.")
                            .font(.subheadline)
                            .foregroundColor(Palette.deepTextColor.opacity(0.85))
                    }
                    .padding(.bottom, 32)
                    .padding(.horizontal)

                    foodSection
                    
                    // Leave party button
                    SubmitButton(title: "Leave party", color: .red, action: {
                        showLeavePartyConfirmation = true
                    })
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
            //} // End of ScrollView
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressOverlay(message: "Loading party details...")

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
                    pollingTimer?.invalidate()
                    pollingTimer = nil
                    sessionManager.showHome(authUser: authUser, appState: appState)
                }
            }
            .alert("You have successfully left this party.", isPresented: $showLeftPartyAlertScreen) {
                Button("OK") {
                    appState.needToRefresh = true
                    pollingTimer?.invalidate()
                    pollingTimer = nil
                    sessionManager.showHome(authUser: authUser, appState: appState)
                }
            }
            .alert("The host has removed you from this party.", isPresented: $showKickedPartyAlert) {
                Button("OK") {
                    appState.needToRefresh = true
                    pollingTimer?.invalidate()
                    pollingTimer = nil
                    sessionManager.showHome(authUser: authUser, appState: appState)
                }
            }
            .alert("Could not leave the party. Please try again.", isPresented: $showDeleteGuestFailureAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
    
    private var foodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Food and Drinks")
                .font(.headline)
                .foregroundColor(Palette.deepTextColor)
                .padding(.horizontal)
            
            List {
                ForEach(viewModel.foods) { food in
                    VStack {
                        HStack {
                            food.statusIcon.foregroundStyle(food.statusColor)
                            Text(food.item_name)
                                .font(.body.weight(.medium))
                                .foregroundColor(Palette.deepTextColor)
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.3))
                        )
                        .padding(.horizontal) // matches guestSection spacing
                        .padding(.bottom, 10) // spacing between rows
                    }
                    .listRowInsets(EdgeInsets()) // remove List's default padding
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing) {
                        Button {
                            viewModel.optimisticallyReportFoodStatus(authUser: authUser, host: host, itemName: food.item_name, newStatus: "out")
                        } label: {
                            Label("Out", systemImage: "exclamationmark.shield.fill")
                        }
                        .tint(.red)
                        
                        Button {
                            viewModel.optimisticallyReportFoodStatus(authUser: authUser, host: host, itemName: food.item_name, newStatus: "low")
                        } label: {
                            Label("Low", systemImage: "exclamationmark.triangle.fill")
                        }
                        .tint(.yellow)
                    }
                }
            }
            .listStyle(.plain)
            .scrollDisabled(false)
            .frame(minHeight: 200)
            .background(Color.clear)
        }
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
