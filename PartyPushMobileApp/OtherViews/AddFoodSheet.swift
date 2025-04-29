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
    @State var itemName = ""
    @Binding var showAddFoodView: Bool
    var onFoodAdded: (() -> Void)?
    @State var showAddFoodErrorAlert = false
    @State private var alertMessage = ""
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
            
            TextField("Item name", text: $itemName)
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing], 15)
            
            Button("Submit"){
                viewModel.addFood(authUser: authUser, itemName: itemName, partyCode: host.party_code, status: "full")
                    {
                    (resp) in DispatchQueue.main.async
                    {
                        if resp == "Success!" {
                            onFoodAdded?()
                            showAddFoodView = false
                            print("\(itemName) added")
                        } else {
                            alertMessage = resp
                            showAddFoodErrorAlert = true
                            print("Something went wrong adding \(itemName)")
                        }
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAddFoodErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please try again.")
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Spacer()
        }
// Code for if we want to add a "Adding Food Item..." loading view
//        .overlay(
//            Group {
//                if viewModel.isLoading {
//                    ZStack {
//                        Color.black.opacity(0.3).ignoresSafeArea()
//                        ProgressView("Adding food item...")
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(12)
//                            .shadow(radius: 10)
//                    }
//                }
//            }
//        )
        .background(Gradient(
            colors: [.blue, .pink]).opacity(0.2))
    }
}

#Preview {
    AddFoodSheet(host: hosts[0], authUser: AuthUser(), showAddFoodView: .constant(true))
}
