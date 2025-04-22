//
//  UserManagementPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import SwiftUI

struct UserManagementPage: View {
    
    @StateObject var viewModel = ViewModel()
    @State private var showAddPartyView = false
    let authUser: AuthUser
//    @State private var showHostingParties = true
//    @State private var showAttendingParties = true
    
    var body: some View {
        VStack
        {
            NavigationSplitView
            {
                List
                {
//                    Toggle(isOn: $showHostingParties) {
//                        Text("Show hosting")
//                    }
//                    Toggle(isOn: $showAttendingParties) {
//                        Text("Show attending")
//                    }
//                    if(showHostingParties)
//                    {
                        Section{
                            ForEach(viewModel.hosting) { host in
                                NavigationLink {
//                                    SandboxView(host: host)
                                    HostManagementPage(host: host, authUser: authUser)
                                } label: {
                                    HostRow(host: host)
                                }
                            }
                            .listRowBackground(Color.pink.opacity(0.1))
                        }
                        header: {
                            Text("Hosting")
                                .font(.headline)
                        }
                    //}
//                    if(showAttendingParties)
//                    {
                        Section{
                            ForEach(viewModel.attending) { host in
                                NavigationLink {
                                    HostManagementPage(host: host, authUser: authUser)
                                } label: {
                                    HostRow(host: host)
                                }
                            }
                            .listRowBackground(Color.blue.opacity(0.1))
                        } header: {
                            Text("Attending")
                                .font(.headline)
                        }
                    //}
                } // End of List
                .background(Gradient(
                    colors: [.blue, .pink]).opacity(0.2))
                .scrollContentBackground(.hidden)
//                .animation(.smooth, value: showAttendingParties)
//                .animation(.smooth, value: showHostingParties)
                .navigationTitle("Your parties")
                .toolbar{
//                    ToolbarItem(placement: .topBarTrailing)
//                    {
                        HStack
                        {
                            Button(action:{
                                showAddPartyView.toggle()
                            })
                            {
                                Label("Join party", systemImage: "magnifyingglass.circle.fill")
                            }
                            .tint(Color(red: 0, green: 0.65, blue: 0))
                            
                            Button(action:{
                                showAddPartyView.toggle()
                            })
                            {
                                Label("New party", systemImage: "plus.circle.fill")
                            }
                            .tint(Color(red: 0, green: 0.65, blue: 0))
                        }
//                    }
                }
            } detail: {
                Text("Your parties")
            }// End of NavigationSplitView
            .overlay(Group {
                if (viewModel.hosting.isEmpty && viewModel.attending.isEmpty)
                {
                    Text("You aren't hosting or attending any parties right now. Try adding or joining a party and swiping down to refresh.")
                }
//                else if(!showHostingParties && !showAttendingParties)
//                {
//                    Text("All parties hidden. Toggle the views to see them.")
//                }
            }
            .padding())
        }
        .sheet(isPresented: $showAddPartyView, content: {
            AddHostSheet(authUser: authUser, showAddPartyView: $showAddPartyView)
        })
        .refreshable {
            viewModel.getPartiesHosting(authUser: authUser)
            viewModel.getPartiesAttending(authUser: authUser)
        }
        .onAppear(perform:{
            sendNotification(authUser: authUser, title: "Party Push", body: "Hi, welcome back to party push!")
            viewModel.getPartiesHosting(authUser: authUser)
            viewModel.getPartiesAttending(authUser: authUser)
        })
    }
}

extension UserManagementPage
{
    class ViewModel: ObservableObject
    {
        @Published var hosting = [Host]()
        @Published var attending = [Host]()
        
        func getPartiesHosting(authUser: AuthUser)
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
                        self?.hosting = hosts
                    }
                }
            }
            task.resume()
        }
        
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
                else if let data = $0, let guests = try? JSONDecoder().decode([Host].self, from: data)
                {
                    for var g in guests {
                        g.isHostedParty = false
                    }
                    DispatchQueue.main.async
                    { [weak self] in
                        self?.attending = guests
                    }
                }
            }
            task.resume()
        }
    }
}

#Preview {
    UserManagementPage(authUser: AuthUser())
}
