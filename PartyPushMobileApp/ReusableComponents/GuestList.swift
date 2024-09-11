//
//  GuestList.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/2/24.
//

import SwiftUI
import JWTDecode

struct GuestList: View {
    
    @StateObject var viewModel = ViewModel()
    let authUser: AuthUser

    var body: some View {
        VStack
        {
            HStack
            {
                Button(action:{
                    viewModel.getPartiesAttending(authUser: authUser)
                })
                {
                    Label("Refresh", systemImage: "arrow.clockwise.circle.fill")
                        .tint(Color(red: 0, green: 0.65, blue: 0))
                }
            }
            .padding()
            
            NavigationSplitView 
            {
                if(viewModel.hosts.isEmpty)
                {
                    Text("You aren't attending any parties right now.")
                }
                List(viewModel.hosts, id: \.self) { host in
                    NavigationLink {
                        HostManagementPage(host: host)
                    } label: {
                        HostRow(host: host)
                    }
                }
                .navigationTitle("Attending")
            }        detail: {
                Text("Select a party")
            }
        }
    }
}

extension GuestList
{
    class ViewModel: ObservableObject
    {
        @Published var hosts = [Host]()
        
        func getPartiesAttending(authUser: AuthUser)
        {
            authorizeCall(authUser: authUser)
            
            let queryItems = [URLQueryItem(name: "cognito_username", value: authUser.cognito_username.uuidString)]
            var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
            urlComps.queryItems = queryItems
            let path = urlComps.url!
            var request = URLRequest(url: path)
            request.httpMethod = "GET"
            request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                } 
                else if let data = $0, let hosts = try? JSONDecoder().decode([Host].self, from: data)
                {
                    // Todo: don't use force unwrap here
                    DispatchQueue.main.async
                    { [weak self] in
                        self?.hosts = hosts
                    }
                }
            }
            task.resume()
        }
        
        func authorizeCall(authUser: AuthUser)
        {
            // check if the email on the idToken matches
            // the email we assigned at login/sign up
            let accessToken = try? decode(jwt: authUser.accessToken)
            let idToken = try? decode(jwt: authUser.idToken)
            let cognito_username_from_accessToken = accessToken?["username"].string ?? "defaultAccessToken"
            let cognito_username_from_idToken = idToken?["cognito:username"].string ?? "defaultIdToken"
            
            if(cognito_username_from_accessToken != cognito_username_from_idToken)
            {
                // if the cognito username of the tokens don't match,
                // then we have a problem and shouldn't be accessing this API
                // Todo: handle here
            }
            else
            {
                // if they do match, we're good to call the API
                // for the requested user's objects
                
                // either cognito_username variable works here
                // since they would be the same in this check
                authUser.cognito_username = UUID(uuidString: cognito_username_from_accessToken) ?? UUID()
            }
        }
    }
}

#Preview {
    GuestList(authUser: AuthUser())
}
