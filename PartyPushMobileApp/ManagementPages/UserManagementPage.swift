//
//  UserManagementPage.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/4/24.
//

import Foundation
import SwiftUI
import AuthenticationServices

//func GetHostsFromUser(completion: @escaping ((String) -> Void))
//{
//    guard let url = URL(string: "https://m5pw23ec4k.execute-api.us-east-1.amazonaws.com/hello")
//    else
//    {
//        return
//    }
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//    let body: [String: AnyHashable] = [
//            "Id": "3",
//            "FirstName": "James",
//            "LastName": "Vallat",
//            "Class": 1946
//    ]
//    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
//    
//    let task = URLSession.shared.dataTask(with: request) {data, _, error in
//        guard let data = data, error == nil else {
//            return
//        }
//        do{
//            let response = try JSONDecoder().decode(Student.self, from: data)
//            completion("Success! \(response.FirstName) \(response.LastName) with id \(response.Id) was created")
//        }
//        catch{
//            print(error)
//        }
//    }
//    task.resume()
//}
//
//func GetGuestsFromUser(completion: @escaping ((String) -> Void))
//{
//    guard let url = URL(string: "https://m5pw23ec4k.execute-api.us-east-1.amazonaws.com/hello")
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
//            var StudentIntros: [String] = []
//            let response = try JSONDecoder().decode([Student].self, from: data)
//            response.forEach{ student in
//                StudentIntros.append(student.FirstName + " " + student.LastName + " with id " + student.Id)
//            }
//            completion("\(StudentIntros)")
//        }
//        catch{
//            print(error)
//        }
//    }
//    task.resume()
//}

struct UserManagementPage: View {
    
//    @EnvironmentObject var authUser: AuthUser
//    @State private var studentToAdd: String = ""
//    @State private var studentList: String = ""
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
