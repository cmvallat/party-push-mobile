//
//  UserManagementPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import Foundation
import SwiftUI
import AuthenticationServices

//func GetHostsFromUser(completion: @escaping (String, Error?) -> Void)
//{
//    guard let url = URL(string: "apigatewayurlhere")
//    else
//    {
//        return
//    }
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    let body: [String: AnyHashable] = [
//            add user object data here
//    ]
//    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
//    
//    let task = URLSession.shared.dataTask(with: request) {data, _, error in
//        guard let data = data, error == nil else {
//            return
//        }
//        do{
//            let response = try JSONDecoder().decode(Host.self, from: data)
//            completion(response.party_code, nil)
//        }
//        catch{
//            print(error)
//        }
//    }
//    task.resume()
//}
//
//private func GetGuestsFromUser(completion: @escaping (String, Error?) -> Void)
//{
//    guard let url = URL(string: "apigatewayurlhere")
//    else
//    {
//        return
//    }
//    var request = URLRequest(url: url)
//    request.httpMethod = "GET"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    
//    let task = URLSession.shared.dataTask(with: request) {data, _, error in
//        guard let data = data, error == nil else {
//            return
//        }
//        do{
//            // fix this up as needed but good proof of concept
////            var hostNames: [String] = []
//            let response = try JSONDecoder().decode([Host].self, from: data)
////            response.forEach{ host in
////                hostNames.append(host.party_name + " " + host.party_code)
////            }
//            completion(response[0].party_name, nil)
//        }
//        catch{
//            print(error)
//        }
//    }
//    task.resume()
//}


struct UserManagementPage: View {
    
    let authUser: AuthUser
    
    var body: some View {
        VStack{
            Spacer()
            
            HostList()
            
            Spacer()
        }
        .padding([.leading,.trailing], 15)
        .background(Gradient(colors: [.blue, .pink]).opacity(0.2))
    }
}

#Preview {
    UserManagementPage(authUser: AuthUser())
}
