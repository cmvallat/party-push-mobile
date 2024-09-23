//
//  UserList.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import SwiftUI

struct HostList: View {
    
    @StateObject var viewModel = ViewModel()
    @State private var showAddPartyView = false
    let authUser: AuthUser

    var body: some View {
        VStack
        {
            HStack
            {
                Button(action:{
                    viewModel.getHosts(authUser: authUser)
                })
                {
                    Label("Refresh", systemImage: "arrow.clockwise.circle.fill")
                        .tint(Color(red: 0, green: 0.65, blue: 0))
                }
                
                Spacer()
                
                Button(action:{
                    showAddPartyView.toggle()
                })
                {
                    Label("New party", systemImage: "plus.circle.fill")
                        .tint(Color(red: 0, green: 0.65, blue: 0))
                }
            }
            .padding()
            
            NavigationSplitView 
            {
                if(viewModel.hosts.isEmpty)
                {
                    Text("You aren't hosting any parties right now.")
                }
                List(viewModel.hosts, id: \.self) { host in
                    NavigationLink {
                        HostManagementPage(host: host)
                    } label: {
                        HostRow(host: host)
                    }
                }
                .navigationTitle("Hosting")
            }        detail: {
                Text("Select a party")
            }
        }
        .sheet(isPresented: $showAddPartyView, content: {
            AddHostSheet(showAddPartyView: $showAddPartyView)
        })
//        .refreshable {
//            viewModel.getHosts(authUser: authUser)
//        }
    }
}

extension HostList
{
    class ViewModel: ObservableObject
    {
        @Published var hosts = [Host]()
        
        func getHosts(authUser: AuthUser)
        {
            let authorizedUser = authorizeCall(authUser: authUser)
            
            let queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString)]
            // Todo: store url somewhere?
            var urlComps = URLComponents(string: "https://wdyj4fn3z3.execute-api.us-east-1.amazonaws.com/Test")!
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
                    DispatchQueue.main.async{
                        [weak self] in
                        self?.hosts = hosts
                    }
                }
            }
            task.resume()
        }
    }
}

#Preview {
    HostList(authUser: AuthUser())
}
