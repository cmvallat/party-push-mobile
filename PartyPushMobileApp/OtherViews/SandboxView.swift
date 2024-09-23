//
//  SandboxView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/23/24.
//

import SwiftUI
import JWTDecode

struct ApiResponseFormat: Codable{
    let statusCode: Int
    let body: String
    let isBase64Encoded: Bool
}

struct SandboxView: View
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

extension SandboxView
{
    class ViewModel: ObservableObject
    {
        @Published var hosts = [Host]()
        
        func getPartiesAttending(authUser: AuthUser)
        {
            var authorizedUser = authorizeCall(authUser: authUser)
            
            let queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString)]
            var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
            urlComps.queryItems = queryItems
            var request = URLRequest(url: urlComps.url!)
            request.httpMethod = "GET"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                }
                else if let data = $0, let attendingParties = try? JSONDecoder().decode([Host].self, from: data)
                {
                    // For debugging purposes:
//                    print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                    DispatchQueue.main.async
                    { [weak self] in
                        self?.hosts = attendingParties
                    }
                }
            }
            task.resume()
        }
    }
}

#Preview {
    SandboxView(authUser: AuthUser())
}

