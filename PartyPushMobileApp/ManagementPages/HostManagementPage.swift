import SwiftUI

struct HostManagementPage: View {
    var host: Host
    let authUser: AuthUser

    @StateObject private var viewModel = HostManagementViewModel()
    @State private var showGuestPopover: Bool = false
    @State private var showAddFoodView = false

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

                Text("Add description here if we want to add it to the Host object schema in the database.")
                    .font(.subheadline)

                Divider()

                List {
                    foodSection
                    guestSection
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
                    if(row.status == "out")
                    {
                        Image(systemName: "exclamationmark.shield.fill").foregroundStyle(.red)
                    }
                    else if(row.status == "low")
                    {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
                    }
                    else if(row.status == "full")
                    {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                    Text(row.item_name)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.deleteFoodItem(authUser: authUser, host: host, itemName: row.item_name)
                                viewModel.refresh(authUser: authUser, host: host)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)

                            Button {
                                viewModel.reportFood(authUser: authUser, itemName: row.item_name, partyCode: host.party_code, status: "low")
                                viewModel.refresh(authUser: authUser, host: host)
                            } label: {
                                Label("Low", systemImage: "exclamationmark.triangle.fill")
                            }
                            .tint(.yellow)

//                            exclamationmark.shield.fill
                            Button {
                                viewModel.reportFood(authUser: authUser, itemName: row.item_name, partyCode: host.party_code, status: "full")
                                viewModel.refresh(authUser: authUser, host: host)
                            } label: {
                                Label("Refilled", systemImage: "arrow.trianglehead.2.counterclockwise")
                            }
                            .tint(.green)
                        }
                    Spacer()
                }
            }
            Button {
                showAddFoodView.toggle()
            } label: {
                Label("Add", systemImage: "plus")
            }
        } header: {
            Text("Food/Drinks").font(.headline)
        }
        .headerProminence(.increased)
    }

    private var guestSection: some View {
        Section {
            ForEach(viewModel.guests) { row in
                HStack {
                    Text(row.guest_name)
                        .swipeActions {
                            Button(role: .destructive) {
                                viewModel.deleteGuest(authUser: authUser, host: host, guest: row)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        } header: {
            HStack {
                Text("Guests").font(.headline)
                Button("", systemImage: "info.circle") {
                    showGuestPopover.toggle()
                }
                .popover(isPresented: $showGuestPopover) {
                    Text("Swipe to remove a guest from your party, and toggle to see current guests only vs all guests.")
                        .font(.caption)
                        .padding()
                }
            }
        }
        .headerProminence(.increased)
    }
}
