import SwiftUI

struct DemoView: View {
    
    var host: Host
    var demoFoodListFromApi: [Food]
    var demoGuestListFromApi: [Guest]
    @State private var showingFoodDeleteAlert: Bool = false
    @State private var showingGuestDeleteAlert: Bool = false
    @State private var showFoodPopover: Bool = false
    
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
                
                List{
                    Section{
                        ForEach(demoFoodListFromApi) { row in
                            HStack {
                                Text(row.item_name)
                                Spacer()
                            }
//                            .padding(50)
                        }
                        .alert("Are you sure you want to remove this item? It will alert all guests that it has been removed from the party.", isPresented: $showingFoodDeleteAlert){
                            Button("Delete", role: .destructive)
                            {
                                print("new delete clause")
                                showingFoodDeleteAlert = false
                            }
                        }
                        .swipeActions(edge: .trailing)
                        {
                            // Delete item button
                            Button {
                                showingFoodDeleteAlert.toggle()
                            }
                            label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            .tint(Color.red)
                            
                            // Report low button
                            Button {
                                print("reported low")
                            }
                            label: {
                                Label("Low", systemImage: "exclamationmark.triangle.fill")
                            }
                            .tint(Color.yellow)
                            
                            // Report refilled button
                            Button {
                                // Todo: change status
                                print("refilled")
                            }
                            label: {
                                Label("Refilled", systemImage: "arrow.trianglehead.2.counterclockwise")
                            }
                            .tint(Color.green)
                            
                        }
                    } header: {
                        Text("Food/Drinks")
                            .font(.headline)
                    }

                    Section{
                        // add toggle for current/invited guests
                            ForEach(demoGuestListFromApi) { row in
                                HStack {
                                    Text(row.guest_name)
                                }
                            }
                            .swipeActions {
                                Button("Remove", role: .destructive) {
                                    showingGuestDeleteAlert = true
                                        }
                                    }
                                    .tint(Color.red)
//                                    .confirmationDialog(
//                                        Text("Are you sure you want to remove this guest from your party?"),
//                                        isPresented: $showingGuestDeleteAlert,
//                                        titleVisibility: .visible
//                                    ) {
//                                         Button("Delete", role: .destructive) {
//                                         withAnimation {
//                                            print("removed guest")
//                                         }
//                                    }
//                                }

                    } header: {
                        HStack{
                            Text("Guests")
                                .font(.headline)
                            Button("", systemImage: "info.circle")
                            {
                                showFoodPopover.toggle()
                            }
                            .popover(isPresented: $showFoodPopover, attachmentAnchor: .point(.bottom), content: {
                                Text("Swipe to remove a guest from your party, and toggle to see current guests only vs all guests (current AND invited).")
                                    .font(.caption)
                                    .presentationCompactAdaptation(.popover)
                                    .padding([.leading, .trailing], 5)
                            })
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
    }
}

#Preview {
    DemoView(host: hosts[0], demoFoodListFromApi: food, demoGuestListFromApi: guests)
}
