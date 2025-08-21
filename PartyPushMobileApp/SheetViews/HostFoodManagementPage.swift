import SwiftUI

struct HostFoodManagementPage: View {
    var host: Host
    let authUser: AuthUser
    @ObservedObject var appState: AppState
    
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = HostManagementViewModel()
    @StateObject private var addFoodViewModel = AddFoodViewModel()
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

                // --- Begin New Food Management Section ---
                Text("Food and Drinks").font(.headline).padding(.bottom, 2)
                List {
                    if viewModel.foods.isEmpty {
                        Text("No current food items")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.foods) { row in
                            HStack {
                                row.statusIcon.foregroundStyle(row.statusColor)
                                Text(row.item_name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .shadow(radius: 3)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
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
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(height: 250)

                HStack {
                    TextField("Enter item name", text: $addFoodViewModel.itemName)
                        .textFieldStyle(.roundedBorder)
                    Button(action: {
                        let trimmed = addFoodViewModel.itemName.trimmingCharacters(in: .whitespaces)
                        if !trimmed.isEmpty {
                            addFoodViewModel.addFood(authUser: authUser, partyCode: host.party_code) { response in
                                print("add food response" + response)
                                if response == "Success!" {
                                    DispatchQueue.main.async {
                                        viewModel.refresh(authUser: authUser, host: host)
                                        addFoodViewModel.itemName = ""
                                    }
                                }
                                // error messaging handled by alert
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .padding(7)
                            .background(Circle().fill(Color.accentColor.opacity(0.15)))
                    }
                    .disabled(addFoodViewModel.itemName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .alert("Error", isPresented: Binding<Bool>(
                    get: { addFoodViewModel.errorMessage != nil },
                    set: { _ in addFoodViewModel.errorMessage = nil }
                )) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(addFoodViewModel.errorMessage ?? "Unknown error")
                }
                // --- End New Food Management Section ---
                guestSection
                HStack {
                    Spacer()
                    Button(action: {
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
                HStack {
                    Spacer()
                    Button(action: {
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
                                viewModel.deleteGuest(authUser: authUser, host: host, guest: row)
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
