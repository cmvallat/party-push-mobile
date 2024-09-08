//
//  GuestList.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 9/2/24.
//

import SwiftUI

struct GuestList: View {
    
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack{
            NavigationSplitView {
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
        .onAppear(perform: viewModel.getPartiesAttending)
    }
}

extension GuestList{
    class ViewModel: ObservableObject{
        @Published var hosts = [Host]()
        @Published var text = ""
        
        func getPartiesAttending()
        {
            let queryItems = [URLQueryItem(name: "name", value: "cmvallat")]
            var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
            urlComps.queryItems = queryItems
            let path = urlComps.url!
            var request = URLRequest(url: path)
            request.httpMethod = "GET"
            
            // Todo: pass in data from AuthUser
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2{
                    print(error)
                } else if let data = $0, let movies = try? JSONDecoder().decode([Host].self, from: data){
                    DispatchQueue.main.async{ [weak self] in
                        self?.hosts = movies
                        self?.text.removeAll()
                    }
                }
            }
            task.resume()
        }
    }
}

#Preview {
    GuestList()
}
