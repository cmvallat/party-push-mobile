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
    @State private var showAddPartyView = false
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
                
                Spacer()
                
                Button(action:{
                    // Todo: add toggle for join party view here
                })
                {
                    Label("Join party", systemImage: "magnifyingglass.circle.fill")
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
//        .refreshable {
//            viewModel.getPartiesAttending(authUser: authUser)
//        }
    }
}

extension GuestList
{
    class ViewModel: ObservableObject
    {
        @Published var hosts = [Host]()
        
        func getPartiesAttending(authUser: AuthUser)
        {
            let authorizedUser = authorizeCall(authUser: authUser)

            let queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString)]
            // Todo: store url somewhere?
            var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
            urlComps.queryItems = queryItems
            // Todo: don't use force unwrap
            var request = URLRequest(url: urlComps.url!)
            request.httpMethod = "GET"
            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
            
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2
                {
                    print(error)
                } 
                else if let data = $0, let hosts = try? JSONDecoder().decode([Host].self, from: data)
                {
                    DispatchQueue.main.async
                    { [weak self] in
                        self?.hosts = hosts
                    }
                }
            }
            task.resume()
        }
    }
}

#Preview {
    GuestList(authUser: AuthUser())
}
