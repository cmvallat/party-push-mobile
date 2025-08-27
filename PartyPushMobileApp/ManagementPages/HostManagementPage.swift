import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct HostManagementPage: View {
    var host: Host
    let authUser: AuthUser
    @ObservedObject var appState: AppState

    @StateObject private var viewModel = HostManagementViewModel()
    @State private var showAddFoodView = false
    @State private var showEndedPartyAlert = false
    
    // For Universal Linking - invite guest
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    
    @EnvironmentObject var sessionManager: SessionManager

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
                    guestSection
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // Construct the universal link with the current party code
                            let universalLink = "https://livepartyhelper.com/join-party/\(host.party_code)"
                            shareURL = URL(string: universalLink)
                            showShareSheet = true
                        }) {
                            Label("Invite Guest", systemImage: "person.crop.circle.badge.plus")
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(12)
                        }
                        .sheet(isPresented: $showShareSheet) {
                            if let url = shareURL {
                                ShareSheet(activityItems: [url])
                            }
                        }
                        .padding(.vertical, 6)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    
//                    Button(action: {
//                        // Construct the universal link with the current party code
//                        let universalLink = "https://yourdomain.com/joinparty?party_code=\(host.party_code)"
//                        shareURL = URL(string: universalLink)
//                        showShareSheet = true
//                    }) {
//                        Label("Invite Guest", systemImage: "person.crop.circle.badge.plus")
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 10)
//                            .background(Color.green)
//                            .cornerRadius(12)
//                    }
//                    .sheet(isPresented: $showShareSheet) {
//                        if let url = shareURL {
//                            ShareSheet(activityItems: [url])
//                        }
//                    }
//                    .padding(.vertical, 6)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            // Your action
                            viewModel.endParty(authUser: authUser, party_code: host.party_code) { res in
                                if res == true {
                                    appState.endedPartyCode = host.party_code
                                }
                            }
                        }) {
                            Text("End party")
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
            }
            .padding()

            Spacer()
        }
        .background(AppBackground())
        .overlay(
            Group {
                if viewModel.isLoading {
//                    ZStack {
//                        Color.black.opacity(0.3).ignoresSafeArea()
//                        ProgressView("Loading party details...")
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(12)
//                            .shadow(radius: 10)
//                    }
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
        }
        .onChange(of: appState.endedPartyCode, initial: true) { _, endedCode in
            if endedCode == host.party_code {
                showEndedPartyAlert = true
            }
        }
        .alert("You have successfully ended this party.", isPresented: $showEndedPartyAlert) {
            Button("OK") {
                print("ALERT BUTTON PRESSED")
                appState.needToRefresh = true
                sessionManager.showHome(authUser: authUser, appState: appState)
            }
        }
    }
    
    private var foodSection: some View {
        Section {
            if viewModel.foods.isEmpty {
                VStack {
                    Text("No food or drinks added yet.")
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
                            .swipeActions(edge: .leading) {
                                Button(role: .destructive) {
                                    viewModel.deleteFoodItem(authUser: authUser, host: host, itemName: row.item_name) {
                                        viewModel.refresh(authUser: authUser, host: host)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
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
                                
                                Button {
                                    viewModel.optimisticallyReportFoodStatus(authUser: authUser, host: host, itemName: row.item_name, newStatus: "full")
                                } label: {
                                    Label("Refilled", systemImage: "arrow.trianglehead.2.counterclockwise")
                                }
                                .tint(.green)
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
            
            // Styled Add Food button
            HStack {
                Spacer()
                Button(action: {
                    showAddFoodView.toggle()
                }) {
                    Label("Add Food", systemImage: "plus")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

        } header: {
            Text("Food and Drinks").font(.headline)
        }
        .headerProminence(.increased)
    }
    
    private var guestSection: some View {
        Section {
            if viewModel.guests.isEmpty {
                VStack {
                    Text("No guests have joined your party yet.")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
            else {
                ForEach(viewModel.guests) { row in
                    HStack {
                        Image(systemName: "person.fill")
                        Text(row.guest_name)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .swipeActions(edge: .leading) {
                                Button(role: .destructive) {
//                                    viewModel.deleteGuest(authUser: authUser, host: host, guest: guest){ res in
//                                        if res == true {
//                                            showRemovedGuestSuccessAlert = true
//                                        }
//                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 3)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        } header: {
            HStack {
                Text("Guests").font(.headline)
            }
        }
        .headerProminence(.increased)
    }
}
