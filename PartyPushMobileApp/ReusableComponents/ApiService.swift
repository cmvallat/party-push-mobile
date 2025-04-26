//
//  ApiService.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/22/25.
//

import Foundation

enum APIService {
    
    static func getPartiesHosting(authUser: AuthUser, completion: @escaping ([Host]) -> Void) {
        let authorizedUser = authorizeCall(authUser: authUser)
        var urlComps = URLComponents(string: "https://wdyj4fn3z3.execute-api.us-east-1.amazonaws.com/Test")!
        urlComps.queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString)]

        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, let hosts = try? JSONDecoder().decode([Host].self, from: data) {
                completion(hosts)
            } else {
                print("Error fetching parties hosting: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
            }
        }.resume()
    }

    static func getPartiesAttending(authUser: AuthUser, completion: @escaping ([Host]) -> Void) {
        let authorizedUser = authorizeCall(authUser: authUser)
        var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
        urlComps.queryItems = [URLQueryItem(name: "cognito_username", value: authorizedUser.cognito_username.uuidString)]

        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        request.setValue(authorizedUser.idToken, forHTTPHeaderField: "AccessToken")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, var guests = try? JSONDecoder().decode([Host].self, from: data) {
                for i in guests.indices {
                    guests[i].isHostedParty = false
                }
                completion(guests)
            } else {
                print("Error fetching parties attending: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
            }
        }.resume()
    }

    static func getFoodList(authUser: AuthUser, host: Host, completion: @escaping ([Food]) -> Void) {
        var urlComps = URLComponents(string: "https://92q2nhqvgb.execute-api.us-east-1.amazonaws.com/Prod")!
        urlComps.queryItems = [
            URLQueryItem(name: "cognito_username", value: authUser.cognito_username.uuidString),
            URLQueryItem(name: "party_code", value: host.party_code)
        ]
        
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil,
                  let decoded = try? JSONDecoder().decode(APIResponse<Food>.self, from: data) else {
                completion([])
                return
            }
            completion(decoded.data)
        }.resume()
    }

    static func getGuestList(authUser: AuthUser, host: Host, completion: @escaping ([Guest]) -> Void) {
        var urlComps = URLComponents(string: "https://sihkfz9re8.execute-api.us-east-1.amazonaws.com/Prod")!
        urlComps.queryItems = [URLQueryItem(name: "party_code", value: host.party_code)]
        
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil,
                  let decoded = try? JSONDecoder().decode(APIResponse<Guest>.self, from: data) else {
                completion([])
                return
            }
            completion(decoded.data)
        }.resume()
    }

    static func deleteFoodItem(authUser: AuthUser, host: Host, itemName: String) {
        var urlComps = URLComponents(string: "https://e8ro13vvl3.execute-api.us-east-1.amazonaws.com/Prod")!
        urlComps.queryItems = [
            URLQueryItem(name: "cognito_username", value: authUser.cognito_username.uuidString),
            URLQueryItem(name: "party_code", value: host.party_code),
            URLQueryItem(name: "item_name", value: itemName)
        ]
        
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "DELETE"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
        
        URLSession.shared.dataTask(with: request).resume()
    }

    static func deleteGuest(authUser: AuthUser, host: Host, guest: Guest) {
        var urlComps = URLComponents(string: "https://sl83ejal53.execute-api.us-east-1.amazonaws.com/Prod")!
        urlComps.queryItems = [
            URLQueryItem(name: "cognito_username", value: guest.cognito_username.uuidString),
            URLQueryItem(name: "party_code", value: host.party_code),
            URLQueryItem(name: "guest_name", value: guest.guest_name)
        ]
        
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "DELETE"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
        
        URLSession.shared.dataTask(with: request).resume()
    }

    static func reportFood(authUser: AuthUser, itemName: String, partyCode: String, status: String, completion: @escaping (String) -> Void) {
        let url = URL(string: "https://bj0fdfpzjb.execute-api.us-east-1.amazonaws.com/Prod")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = Food(
            item_name: itemName,
            party_code: partyCode,
            status: status,
            username: authUser.username,
            cognito_username: authUser.cognito_username
        )
        
        guard let encoded = try? JSONEncoder().encode(payload) else {
            print("Failed to encode food report payload")
            return
        }
        
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, let response = try? JSONDecoder().decode(ApiResponseFormat.self, from: data) {
                completion(response.body)
            } else {
                print("Error reporting food or decoding response:", error?.localizedDescription ?? "Unknown error")
                completion("Something went wrong in addUser call")
            }
        }.resume()
    }
}
