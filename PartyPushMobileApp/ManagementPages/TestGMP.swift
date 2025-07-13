import SwiftUI

// Sample data models matching those used on GMP/HMP
struct MockHost: Identifiable {
    let id = UUID()
    let party_name: String
    let party_code: String
    let description: String?
}

struct MockFood: Identifiable {
    let id = UUID()
    let item_name: String
    let status: String
}

struct MockGuest: Identifiable {
    let id = UUID()
    let guest_name: String
}

struct TestGMP: View {
    let host = MockHost(party_name: "Test Party", party_code: "1234ABCD", description: "A fun test party for previewing UI!")
    
    @State private var foods = [
        MockFood(item_name: "Chips and salsa", status: "full"),
        MockFood(item_name: "Guac", status: "low"),
        MockFood(item_name: "Soda", status: "out"),
        MockFood(item_name: "Coke", status: "full"),
        MockFood(item_name: "Water", status: "low"),
        MockFood(item_name: "Moonshine", status: "out")
    ]
    
    let guests = [
        MockGuest(guest_name: "Alice"),
        MockGuest(guest_name: "Bob"),
        MockGuest(guest_name: "Charlie")
    ]
    
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
                    SubmitButton(title: "Leave party", action: {
                        
                    })
                    
                    Spacer()
                }
                .padding(.bottom, 32)
            //} // End of Scroll View
        } // End of ZStack
    } // End of View

    private var guestSection: some View {
        Section {
            VStack(spacing: 10) {
                HStack {
                    Text("Other Guests")
                        .font(.headline)
                        .foregroundColor(Palette.deepTextColor)
                    Spacer()
                }

                ForEach(guests) { guest in
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(Palette.backgroundPurple)
                        Text(guest.guest_name)
                            .font(.body.weight(.medium))
                            .foregroundColor(Palette.deepTextColor)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(14)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var foodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Food and Drinks")
                .font(.headline)
                .foregroundColor(Palette.deepTextColor)
                .padding(.horizontal)

            List {
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
                        Button("Refilled") { /* action */ }.tint(.green)
                    }
                    .swipeActions(edge: .leading) {
                        Button("Delete") { /* action */ }.tint(.red)
                    }
                }
            }
            .listStyle(.plain)
            .scrollDisabled(false)
            .frame(minHeight: 200)
            .background(Color.clear)
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
    TestGMP()
}
