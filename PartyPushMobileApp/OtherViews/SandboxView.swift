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
    
    var host: Host
//    var demoFoodListFromApi: [Food]
//    var demoGuestListFromApi: [Guest]
//    @StateObject var viewModel = ViewModel()
    let authUser: AuthUser
//    @State private var showingFoodDeleteAlert: Bool = false
//    @State private var showingGuestDeleteAlert: Bool = false
//    @State private var showFoodPopover: Bool = false
//    @State private var showAddPartyView = false
//    @State private var itemToDelete: Food?

    
    var body: some View {
        VStack
        {
            Text("Hello World")
        }
//        .sheet(isPresented: $showAddPartyView, content: {
//            AddHostSheet(authUser: authUser, showAddPartyView: $showAddPartyView)
//        })
//        .refreshable {
//            viewModel.getPartiesHosting(authUser: authUser)
//            viewModel.getPartiesAttending(authUser: authUser)
//        }
//        .onAppear(perform:{
//            sendNotification(authUser: authUser, title: "Party Push", body: "Hi, welcome back to party push!")
//            viewModel.getPartiesHosting(authUser: authUser)
//            viewModel.getPartiesAttending(authUser: authUser)
//        })
    }
}

//extension SandboxView
//{
//    class ViewModel: ObservableObject
//    {
//        @Published var hosting = [Host]()
//        @Published var attending = [Host]()
//        
//        func getPartiesHosting(authUser: AuthUser)
//        {
//            let authorizedUser = authorizeCall(authUser: authUser)
//            
//            let queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString)]
//            // Todo: store url somewhere?
//            var urlComps = URLComponents(string: "https://wdyj4fn3z3.execute-api.us-east-1.amazonaws.com/Test")!
//            urlComps.queryItems = queryItems
//            // Todo: don't use force unwrap
//            var request = URLRequest(url: urlComps.url!)
//            request.httpMethod = "GET"
//            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
//            
//            let task = URLSession.shared.dataTask(with: request){
//                if let error = $2
//                {
//                    print(error)
//                }
//                else if let data = $0, let hosts = try? JSONDecoder().decode([Host].self, from: data)
//                {
//                    DispatchQueue.main.async{
//                        [weak self] in
//                        self?.hosting = hosts
//                    }
//                }
//            }
//            task.resume()
//        }
//        
//        func getPartiesAttending(authUser: AuthUser)
//        {
//            let authorizedUser = authorizeCall(authUser: authUser)
//
//            let queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString)]
//            // Todo: store url somewhere?
//            var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
//            urlComps.queryItems = queryItems
//            // Todo: don't use force unwrap
//            var request = URLRequest(url: urlComps.url!)
//            request.httpMethod = "GET"
//            request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")
//            
//            let task = URLSession.shared.dataTask(with: request){
//                if let error = $2
//                {
//                    print(error)
//                }
//                else if let data = $0, let guests = try? JSONDecoder().decode([Host].self, from: data)
//                {
//                    for var g in guests {
//                        g.isHostedParty = false
//                    }
//                    DispatchQueue.main.async
//                    { [weak self] in
//                        self?.attending = guests
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
//}

#Preview {
    SandboxView(host:hosts[0], authUser: AuthUser())
//    HostList(authUser: AuthUser())
}
