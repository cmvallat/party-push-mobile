import SwiftUI

struct DemoListView: View {
    @State private var demoItems: [String] = []
    @State private var newItemName: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Foods/Drink").font(.title2).padding(.leading)
            List {
                if demoItems.isEmpty {
                    Text("No current food items")
                        .foregroundColor(.secondary)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(demoItems, id: \.self) { item in
                        Text(item)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .frame(height: 250)
            
            HStack {
                TextField("Enter item name", text: $newItemName)
                    .textFieldStyle(.roundedBorder)
                Button(action: {
                    let trimmed = newItemName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        demoItems.append(trimmed)
                        newItemName = ""
                    }
                }) {
                    Image(systemName: "plus")
                        .padding(7)
                        .background(Circle().fill(Color.accentColor.opacity(0.15)))
                }
                .disabled(newItemName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding(.top, 12)
    }
}

#Preview {
    DemoListView()
}
