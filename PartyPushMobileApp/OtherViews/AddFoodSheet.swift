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
    @State var showAddFoodErrorAlert = false
    @State private var alertMessage = ""
    @StateObject var viewModel = ViewModel()
    
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
                        if(resp == "Success!")
                        {
                            showAddFoodView.toggle()
                        }
                        else
                        {
                            alertMessage = resp
                            showAddFoodErrorAlert = true
                        }
                    }
                }
                print("\(itemName) added")
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
        .background(Gradient(
            colors: [.blue, .pink]).opacity(0.2))
    }
}

extension AddFoodSheet{
    class ViewModel: ObservableObject{
        @Published var response = ""
        
        func addFood(authUser: AuthUser, itemName: String, partyCode: String, status: String, completion: @escaping (String) -> Void)
        {
            let authorizedUser = authorizeCall(authUser: authUser)
            
            // Todo: store url somewhere?
            let path = "https://nm1c3v9jc9.execute-api.us-east-1.amazonaws.com/Prod"
            
            // Todo: don't use force unwrap
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "POST"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let foodToAdd = Food(
                item_name: itemName,
                party_code: partyCode,
                status: status,
                username: "cmvallattest",
                cognito_username: authorizedUser.cognito_username)
            
            if let foodData = try? JSONEncoder().encode(foodToAdd){
                request.httpBody = foodData
            }
            
            // Todo: standardize error handling here and in other API calls
            let task = URLSession.shared.dataTask(with: request){
                if $2 != nil
                {
                    completion("Uh oh! Something went wrong")
                }
                else if let data = $0
                {
                    // decode to string because it won't return the added object, just a success or failure message
                    if let decoded = try? JSONDecoder().decode(APIResponse<EmptyCodable>.self, from: data) {
                        completion(decoded.message)
                    } else {
                        completion("Uh oh! Something went wrong")
                    }
                    
                    // For debugging:
//                    print("---> data: \n \((String(data: data, encoding: .utf8) ?? "nil") as String) \n")
                }
                else
                {
                    completion("Uh oh! Something went wrong")
                }
            }
            task.resume()
        } //End of function
        
    }
}

#Preview {
    AddFoodSheet(host: hosts[0], authUser: AuthUser(), showAddFoodView: .constant(true))
}
