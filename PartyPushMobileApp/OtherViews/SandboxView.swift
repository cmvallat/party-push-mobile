//
//  SandboxView.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/23/24.
//


import SwiftUI

// Todo: move to Common
struct ApiResponseFormat: Codable{
    let statusCode: Int
    let body: String
    let isBase64Encoded: Bool
}

struct SandboxView: View {
    
    @StateObject var viewModel = ViewModel()
    @State private var showAddPartyView = false
    let authUser: AuthUser
    // for testing:
    let demoHostList: [Host]
    @State private var showHostingParties = true
    @State private var showAttendingParties = true

    var hostingParties: [Host] {
        demoHostList.filter { h in
            (showHostingParties && h.username == "christianvallat")
        }
    }
    
    var attendingParties: [Host] {
        demoHostList.filter { h in
            (showAttendingParties && h.username != "christianvallat")
        }
    }
    
    var body: some View {
        VStack
        {

            NavigationSplitView
            {
                    List{
                        Toggle(isOn: $showHostingParties) {
                            Text("Show hosting")
                        }
                        Toggle(isOn: $showAttendingParties) {
                            Text("Show attending")
                        }
                        if(showHostingParties)
                        {
                            Section{
                                ForEach(hostingParties) { host in
                                    NavigationLink {
//                                        HostManagementPage(host: host)
                                    } label: {
                                        HostRow(host: host)
                                    }
                                }
                                .listRowBackground(Color.pink.opacity(0.1))
                            }
                            header: {
                                Text("Parties you're hosting")
                                    .font(.headline)
                            }
                        }
                        if(showAttendingParties)
                        {
                            Section{
                                ForEach(attendingParties) { host in
                                    NavigationLink {
//                                        HostManagementPage(host: host)
                                    } label: {
                                        HostRow(host: host)
                                    }
                                }
                                .listRowBackground(Color.blue.opacity(0.1))
                            } header: {
                                Text("Parties you're attending")
                                    .font(.headline)
                            }
                        }
                    }
                    .background(Gradient(
                        colors: [.blue, .pink]).opacity(0.2))
                    .scrollContentBackground(.hidden)
                    .animation(.smooth, value: showAttendingParties)
                    .animation(.smooth, value: showHostingParties)
                    .navigationTitle("Select a party")
                    .toolbar{
                        ToolbarItem(placement: .topBarTrailing)
                        {
                            HStack{
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
                        }
//                        ToolbarItem(placement: .topBarTrailing)
//                        {
//
//                        }
                    }
                } detail: {
                    Text("Select a party")
            }
                .overlay(Group {
                    if (hostingParties.isEmpty && attendingParties.isEmpty)
                    {
                        Text("You aren't hosting or attending any parties right now. Try adding or joining a party and swiping down to refresh.")
                    }
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

extension SandboxView
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
    SandboxView(authUser: AuthUser(), demoHostList: [hosts[0], hosts[1], hosts[2], hosts[3], hosts[4]])
//    HostList(authUser: AuthUser())
}
