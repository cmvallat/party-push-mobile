import SwiftUI

struct TestHMP: View {
    let host = MockHost(party_name: "Test Party", party_code: "1234ABCD", description: "A fun test party for previewing UI!")
    
    @State private var foods = [
        MockFood(item_name: "Chips and salsa", status: "full"),
        MockFood(item_name: "Guac", status: "low"),
        MockFood(item_name: "Soda", status: "out"),
        MockFood(item_name: "Coke", status: "full"),
        MockFood(item_name: "Water", status: "low"),
        MockFood(item_name: "Moonshine", status: "out")
    ]
    // For testing empty array, comment out foods above and replace with:
//    @State private var foods: [MockFood] = []
    
    let guests = [
        MockGuest(guest_name: "Alice"),
        MockGuest(guest_name: "Bob"),
        MockGuest(guest_name: "Charlie"),
        MockGuest(guest_name: "Dennis"),
        MockGuest(guest_name: "Eric"),
        MockGuest(guest_name: "Frank"),
        MockGuest(guest_name: "Greg"),
        MockGuest(guest_name: "Harris"),
        MockGuest(guest_name: "Ian")
    ]
    
    @State private var currentFoodItem: String = ""
    @State private var showingAddFoodErrorAlert = false
    
    private func tryAddFood() {
        let trimmed = currentFoodItem.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showingAddFoodErrorAlert = true
            return
        }
        if trimmed.lowercased() == "nil" {
            showingAddFoodErrorAlert = true
            return
        }
        foods.append(MockFood(item_name: trimmed, status: "full"))
        currentFoodItem = ""
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: Palette.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
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

                    VStack(alignment: .leading, spacing: 0) {
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
                    guestSection
                    
                    VStack {
                        SubmitButton(title: "Invite Guest", systemImageName: "person.crop.circle.badge.plus", color: Color.green, action: {
                            // Invite Guest action
                        })
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 10)
        //                .padding(.vertical, 4)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        
                        SubmitButton(title: "Leave party", systemImageName: "door.right.hand.open", color: Color.red, action: {
                            // Leave Party action
                        })
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 32)
            } // End of Scroll View
            .refreshable {
                //action
            }
        } // End of ZStack
    } // End of View

    private var guestSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Guests")
                .font(.headline)
                .foregroundColor(Palette.deepTextColor)
                .padding(.horizontal)
            
            List {
                ForEach(guests) { guest in
                    VStack {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(Palette.backgroundPurple)
                            Text(guest.guest_name)
                                .font(.body.weight(.medium))
                                .foregroundColor(Palette.deepTextColor)
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.3))
                        )
                        .padding(.bottom, 10)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .leading) {
                        Button("Delete") { /* action */ }
                            .tint(.red)
                            .padding()
                    }
                }
            }
            .listStyle(.plain)
            .scrollDisabled(false)
            .frame(minHeight: 200)
            .background(Color.clear)
        }
        .padding(.horizontal)
    }
    
    private var foodSection: some View {
        let isAddEnabled = !currentFoodItem.trimmingCharacters(in: .whitespaces).isEmpty

        return VStack(alignment: .leading, spacing: 10) {
            Text("Food and Drinks")
                .font(.headline)
                .foregroundColor(Palette.deepTextColor)
                .padding(.horizontal)

            List {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.16))
                    HStack {
                        Button(action: { tryAddFood(); dismissKeyboard() }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding(.leading, 12)
                        }
                        TextField(
                            "",
                            text: $currentFoodItem,
                            prompt: Text("Enter item name").foregroundColor(.white)
                        )
                        .onSubmit { tryAddFood() }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .font(.body.weight(.medium))
                    }
                }
                .frame(height: 56)
                .padding(.horizontal)
                .padding(.bottom, 10)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

                if foods.isEmpty {
                    VStack {
                        Text("No food or drinks added yet.")
                            .font(.headline)
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                    }
                    .listRowBackground(Color.clear)
                } else {
                        ForEach(foods) { food in
                            VStack {
                                HStack {
                                    foodStatusIcon(for: food.status)
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
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing) {
                                Button("Out") { /* action */ }.tint(.red)
                                Button("Low") { /* action */ }.tint(.yellow)
                            }
                            .swipeActions(edge: .leading) {
                                Button("Delete") { /* action */ }.tint(.red)
                            }
                        }
                    }
            }
            .listStyle(.plain)
            .scrollDisabled(false)
            .frame(minHeight: 200)
            .background(Color.clear)
            .alert("Failed to add food item", isPresented: $showingAddFoodErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a non-empty item name.")
            }
        }
    }

    
    @ViewBuilder
    private func foodStatusIcon(for status: String) -> some View {
        switch status {
        case "full": Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
        case "low": Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellow)
        case "out": Image(systemName: "xmark.circle.fill").foregroundColor(.red)
        default: Image(systemName: "circle").foregroundColor(.gray)
        }
    }
}

#Preview {
    TestHMP()
}
