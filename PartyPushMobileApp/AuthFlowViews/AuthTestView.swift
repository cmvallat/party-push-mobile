//
//  AuthTestView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/2/24.
//

import SwiftUI

struct Movie: Identifiable, Codable{
    let username: String
    let password: String
    let phone_number: String
    
    var id: String{
        username
    }
}

struct AuthTestView: View {
    
    let authUser: AuthUser
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack{
            List(viewModel.hosts, id: \.self) { host in
                NavigationLink {
                    HostManagementPage(host: host)
                } label: {
                    HostRow(host: host)
                }
            }
            
            HStack{
                TextField("enter a username to fetch host parties", text: $viewModel.text)
                
                Button("Send", action: viewModel.addUser)
            }
            .padding()
        }
    }
}

extension AuthTestView{
    class ViewModel: ObservableObject{
        @Published var hosts = [Host]()
        @Published var text = ""
        
        func addUser(){
            let path = "apigatewayurlhere"
            var request = URLRequest(url: URL(string: path)!)
            request.httpMethod = "POST"
            
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
    AuthTestView(authUser: AuthUser())
}
