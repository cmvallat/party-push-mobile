//
//  AuthTestView.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/2/24.
//

import SwiftUI
import JWTDecode

struct Movie: Identifiable, Codable{
    let username: String
    let password: String
    let phone_number: String
    
    var id: String{
        username
    }
}

struct ApiResponseFormat: Codable{
    let statusCode: Int
    let body: String
    let isBase64Encoded: Bool
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
//            Text($viewModel.response)
            
            HStack{
                TextField("enter a username", text: $viewModel.text)
                
                Button("Send", action:
                        {
                    viewModel.getPartiesAttending(auth: authUser)
                })
            }
            .padding()
        }
    }
}

extension AuthTestView{
    class ViewModel: ObservableObject
    {
        @Published var hosts = [Host]()
        @Published var text = ""
        
        func getPartiesAttending(auth: AuthUser)
        {
            // check if the email on the idToken matches
            // the email we assigned at login/sign up
            let jwt = try? decode(jwt: auth.idToken)
            if let jwtEmail = jwt?["email"].string {
                if(jwtEmail == auth.email)
                {
                    print("worked")
                }
                else
                {
                    print("didnt work")
                }
            }

            let queryItems = [URLQueryItem(name: "name", value: "cmvallat")]
            var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
            urlComps.queryItems = queryItems
            let path = urlComps.url!
            var request = URLRequest(url: path)
            request.httpMethod = "GET"
            request.setValue(auth.idToken, forHTTPHeaderField: "AccessToken")
            
            // Todo: pass in data from AuthUser
            let task = URLSession.shared.dataTask(with: request){
                if let error = $2{
                    print(error)
                } else if let data = $0
                {
                    print("---> data: \n \(String(data: data, encoding: .utf8) as AnyObject) \n")
                    let movies = try? JSONDecoder().decode([Host].self, from: data)
                    DispatchQueue.main.async{ [weak self] in
                        self?.hosts = movies!
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
