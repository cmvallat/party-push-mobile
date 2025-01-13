//
//  AddHostSheet.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/15/24.
//

import SwiftUI

struct AddHostSheet: View
{
    let authUser: AuthUser
    @State var partyName = ""
    @State var partyCode = ""
    @Binding var showAddPartyView: Bool
    @State private var inviteOnly: Bool = false
    @StateObject var viewModel = ViewModel()
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Spacer()
                Button(action:{
                    showAddPartyView.toggle()
                })
                {
                    Label("", systemImage: "xmark.circle.fill")
                }
            }
            .padding(.top, 5)
            
            Spacer()
            
            Text("Create New Party")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding([.leading,.trailing], 15)
            
            TextField("Party Name", text: $partyName)
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing], 15)
            
            TextField("Party Code", text: $partyCode)
                .textFieldStyle(.roundedBorder)
                .padding([.leading,.trailing], 15)
            
            Toggle(isOn: $inviteOnly) {
                    Text("Private party")
                  }
            .toggleStyle(StyleHelpers.CheckboxToggleStyle())
                  .padding()
            
            Button{
                viewModel.addHost(
                    authUser: authUser,
                    partyName: partyName,
                    partyCode: partyCode,
                    isPrivate: inviteOnly ? 1 : 0)
                {
                (resp) in DispatchQueue.main.async
                {
                    // if we successfully added a host, dismiss the sheet to go back to UMPage
                    if(resp == "Success!")
                    {
                        showAddPartyView.toggle()
                    }
                }
            }
                print("\(partyName) created")
            }
            label: {
                Label("Submit", systemImage: "arrowshape.turn.up.forward.fill")
                    .tint(Color(red: 0, green: 0.65, blue: 0))
            }

            Spacer()
        }
        .background(Gradient(
            colors: [.blue, .pink]).opacity(0.2))
    }
}

extension AddHostSheet{
    class ViewModel: ObservableObject{
        @Published var response = ""
        
        func addHost(authUser: AuthUser, partyName: String, partyCode: String, isPrivate: Int, completion: @escaping (String) -> Void)
        {
            let authorizedUser = authorizeCall(authUser: authUser)
            
            // Todo: store url somewhere?
            let path = "https://34eb9x2j6f.execute-api.us-east-1.amazonaws.com/Prod/hello"
            
            // Todo: don't use force unwrap
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "POST"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let hostToAdd = Host(
                username: "Cmvallattest",
                party_name: partyName,
                party_code: partyCode,
                invite_only: isPrivate,
                cognito_username: authorizedUser.cognito_username)
            
            if let hostData = try? JSONEncoder().encode(hostToAdd){
                request.httpBody = hostData
            }
            
            // Todo: standardize error handling here and in other API calls
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    completion("first if statement error")
                }
                else if let data = $0
                {
                    let apiResponse = try? JSONDecoder().decode(ExampleAPIResponse.self, from: data)
                    
                    print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                    
                    completion(apiResponse?.message ?? "failed to decode")
                }
                else
                {
                    completion("else clause error")
                }
            }
            task.resume()
        }
    }
}

#Preview {
    AddHostSheet(authUser: AuthUser(), showAddPartyView: .constant(true))
}
