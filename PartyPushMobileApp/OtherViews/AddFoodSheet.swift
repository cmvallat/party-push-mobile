//
//  AddFoodSheet.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/22/25.
//

import SwiftUI

struct AddFoodSheet: View
{
    let host: Host
    let authUser: AuthUser
    @Binding var showAddFoodView: Bool
    @State var showAddFoodErrorAlert = false
    var onFoodAdded: (() -> Void)?
    @StateObject var viewModel = AddFoodViewModel()
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Spacer()
                Button(action:{
                    showAddFoodView.toggle()
                })
                {
                    Label("", systemImage: "xmark.circle.fill")
                }
            }
            .padding(.top, 5)
            
            Spacer()
            
            Text("Add Food Item")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding([.leading,.trailing], 15)
            
            TextField("Item name", text: $viewModel.itemName)
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing], 15)
            
            // Styled Add Host button
            HStack {
                Spacer()
                Button(action: {
                    viewModel.addFood(authUser: authUser, partyCode: host.party_code)
                    {
                        (resp) in DispatchQueue.main.async
                        {
                            if resp == "Success!" {
                                onFoodAdded?()
                                showAddFoodView = false
                                print("\($viewModel.itemName) added")
                            } else {
                                showAddFoodErrorAlert = true
                                print("Something went wrong adding \($viewModel.itemName)")
                            }
                        }
                    }
                }) {
                    Label("Submit", systemImage: "arrowshape.turn.up.forward.fill")
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            Spacer()
        }
        .background(AppBackground())
        .alert("Error", isPresented: Binding<Bool>(
           get: { viewModel.errorMessage != nil },
           set: { _ in viewModel.errorMessage = nil }
        )) {
           Button("OK", role: .cancel) {}
        } message: {
           Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

#Preview {
    AddFoodSheet(host: hosts[0], authUser: AuthUser(), showAddFoodView: .constant(true))
}
