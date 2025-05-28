import SwiftUI

struct GuestManagementPage: View {
    var host: Host
    let authUser: AuthUser

    @StateObject private var viewModel = GuestManagementViewModel()
    @State private var showGuestPopover: Bool = false
    @State private var showAddFoodView = false
    @State private var showLeavePartyConfirmation = false

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
                    .alert("Are you sure you want to leave this party?", isPresented: $showLeavePartyConfirmation) {
                        Button("Leave", role: .destructive) {
                            viewModel.deleteGuest(
                                authUser: authUser,
                                party_code: host.party_code,
                                username: authUser.username
                            )
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .padding()

            Spacer()
        }
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
        }
    }

    private var foodSection: some View {
        Section {
            ForEach(viewModel.foods) { row in
                HStack {
                    // display a helpful icon based on the food item's current status
                    row.statusIcon.foregroundStyle(row.statusColor)

                    Text(row.item_name)
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
            }
        } header: {
            Text("Food/Drinks").font(.headline)
        }
        .headerProminence(.increased)
    }
}
