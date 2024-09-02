//
//  UserList.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 8/30/24.
//

import SwiftUI

struct HostList: View {
    
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
                .navigationTitle("Host parties")
            }    detail: {
                Text("Select a party")
            }
        }
        .onAppear(perform: viewModel.getHosts)
    }
}

extension HostList{
    class ViewModel: ObservableObject{
        @Published var hosts = [Host]()
        @Published var text = ""
        
        func getHosts(){
            let path = "apigatewayurlhere"
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "POST"
            
            // Todo: pass in data from AuthUser
            let movie = Movie(username: "testusername", password: "testpassword", phone_number: "testphonenumber")
            if let movieData = try? JSONEncoder().encode(movie){
                request.httpBody = movieData
            }
            
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
    HostList()
}
