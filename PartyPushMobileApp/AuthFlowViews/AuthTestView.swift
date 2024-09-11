//
//  AuthTestView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/2/24.
//

import SwiftUI
import JWTDecode

struct ApiResponseFormat: Codable{
    let statusCode: Int
    let body: String
    let isBase64Encoded: Bool
}

struct AuthTestView: View 
{
    let authUser: AuthUser
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack{
            if(viewModel.hosts.isEmpty)
            {
                Text("none")
            }
            else
            {
                List(viewModel.hosts, id: \.self) { host in
                    NavigationLink {
                        HostManagementPage(host: host)
                    } label: {
                        HostRow(host: host)
                    }
                }
            }

            HStack{
                Button("Send", action:
                        {
                    viewModel.getPartiesAttending(authUser: authUser)
                })
            }
            .padding()
        }
    }
}

extension AuthTestView
{
    class ViewModel: ObservableObject
    {
        @Published var hosts = [Host]()
        
        func getPartiesAttending(authUser: AuthUser)
        {
            authorizeCall(authUser: authUser)
            
            // setup the GET request
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
                else if let data = $0
                {
                    // For debugging purposes:
//                    print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                    let attendingParties = try? JSONDecoder().decode([Host].self, from: data)
                    DispatchQueue.main.async
                    { [weak self] in
                        // Todo: don't use force unwrap here
                        self?.hosts = attendingParties!
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
    AuthTestView(authUser: AuthUser())
}
