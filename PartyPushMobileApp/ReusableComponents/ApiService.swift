//
//  ApiService.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/22/25.
//

import Foundation

enum APIService {
    
    static func getPartiesHosting(authUser: AuthUser, completion: @escaping ([Host]) -> Void) {
        var urlComps = URLComponents(string: "https://wdyj4fn3z3.execute-api.us-east-1.amazonaws.com/Test")!
        urlComps.queryItems = [URLQueryItem(name: "username", value: authUser.username)]

        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, let hosts = try? JSONDecoder().decode([Host].self, from: data) {
                print("---> data: \n \((String(data: data, encoding: .utf8) ?? "nil") as String) \n")
                completion(hosts)
            } else {
                print("Error fetching parties hosting: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
            }
        }.resume()
    }

    static func getPartiesAttending(authUser: AuthUser, completion: @escaping ([Host]) -> Void) {
        var urlComps = URLComponents(string: "https://phmbstdnr3.execute-api.us-east-1.amazonaws.com/Test")!
        urlComps.queryItems = [URLQueryItem(name: "username", value: authUser.username)]

        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")

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
            URLQueryItem(name: "username", value: authUser.username),
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
            completion(decoded.data ?? [])
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
            completion(decoded.data ?? [])
        }.resume()
    }
    
    static func getUser(username: String, completion: @escaping (User?) -> Void) {
        var urlComps = URLComponents(string: "https://9bn7w86we7.execute-api.us-east-1.amazonaws.com/Prod/hello")!
        urlComps.queryItems = [URLQueryItem(name: "username", value: username)]
        
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(APIResponse<User>.self, from: data)
                    completion(decoded.data?.first) // might be nil if user is not found
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(nil)
                }
            }.resume()
    }
    
    static func registerDeviceToken(username: String, deviceToken: String, completion: @escaping (String) -> Void) {
        var urlComps = URLComponents(string: "https://qyb4z6bik0.execute-api.us-east-1.amazonaws.com/Prod/hello")!
        urlComps.queryItems = [URLQueryItem(name: "username", value: username),
                               URLQueryItem(name: "deviceToken", value: deviceToken)
        ]
        
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil,
                  let decoded = try? JSONDecoder().decode(APIResponse<EmptyCodable>.self, from: data) else {
                completion("failed to decode message")
                return
            }
            completion(decoded.message)
        }.resume()
    }

    static func deleteFoodItem(authUser: AuthUser, host: Host, itemName: String) {
        var urlComps = URLComponents(string: "https://e8ro13vvl3.execute-api.us-east-1.amazonaws.com/Prod")!
        urlComps.queryItems = [
            URLQueryItem(name: "username", value: authUser.username),
            URLQueryItem(name: "party_code", value: host.party_code),
            URLQueryItem(name: "item_name", value: itemName)
        ]
        
        var request = URLRequest(url: urlComps.url!)
        request.httpMethod = "DELETE"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
        
        URLSession.shared.dataTask(with: request).resume()
    }

    static func deleteGuest(authUser: AuthUser, party_code: String, username: String) {
        var urlComps = URLComponents(string: "https://sl83ejal53.execute-api.us-east-1.amazonaws.com/Prod")!
        urlComps.queryItems = [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "party_code", value: party_code),
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
            username: authUser.username
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
    
    static func addUser(authUser: AuthUser, completion: @escaping (Result<Void, APIError>) -> Void) {
//        print("addUser idToken: " + authUser.idToken)
//        print("addUser accessToken: " + authUser.accessToken)
//        print("addUser username: " + authUser.username)
//        print("addUser password: " + authUser.password)
//        print("addUser email: " + authUser.email)
    
        guard let url = URL(string: "https://2gpkw0jelj.execute-api.us-east-1.amazonaws.com/Prod/hello") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")

        let userToAdd = User(
            username: authUser.username,
            email: authUser.email,
            sns_endpoint_arn: nil
        )

        do {
            request.httpBody = try JSONEncoder().encode(userToAdd)
        } catch {
            completion(.failure(.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                print("---> data: \n \((String(data: data, encoding: .utf8) ?? "nil") as String) \n")
                let decodedResponse = try JSONDecoder().decode(APIResponse<EmptyCodable>.self, from: data)
                if decodedResponse.message == "Success!" {
                    completion(.success(()))
                } else {
                    completion(.failure(.serverError(decodedResponse.message)))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    static func addFoodItem(authUser: AuthUser, itemName: String, partyCode: String, status: String, completion: @escaping (String) -> Void)
    {
//        let authorizedUser = authorizeCall(authUser: authUser)
        
        // Todo: store url somewhere?
        let path = "https://nm1c3v9jc9.execute-api.us-east-1.amazonaws.com/Prod"
        
        // Todo: don't use force unwrap
        var request = URLRequest(url: URL(string: path)!)
        request.httpMethod = "POST"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")
        
        let foodToAdd = Food(
            item_name: itemName,
            party_code: partyCode,
            status: status,
            username: authUser.username)
        
        if let foodData = try? JSONEncoder().encode(foodToAdd){
            request.httpBody = foodData
        }
        
        // Todo: standardize error handling here and in other API calls
        let task = URLSession.shared.dataTask(with: request){
            if $2 != nil
            {
                completion("Uh oh! Something went wrong")
            }
            else if let data = $0
            {
                // decode to string because it won't return the added object, just a success or failure message
                if let decoded = try? JSONDecoder().decode(APIResponse<EmptyCodable>.self, from: data) {
                    completion(decoded.message)
                } else {
                    completion("Uh oh! Something went wrong")
                }
                
                // For debugging:
//                    print("---> data: \n \((String(data: data, encoding: .utf8) ?? "nil") as String) \n")
            }
            else
            {
                completion("Uh oh! Something went wrong")
            }
        }
        task.resume()
    } //End of function
    
    static func addHost(authUser: AuthUser, partyName: String, partyCode: String, inviteOnly: Int, description: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "https://34eb9x2j6f.execute-api.us-east-1.amazonaws.com/Prod/hello") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")

        let hostToAdd = Host(
            username: authUser.username,
            party_name: partyName,
            party_code: partyCode,
            invite_only: inviteOnly,
            description: description
        )

        do {
            request.httpBody = try JSONEncoder().encode(hostToAdd)
        } catch {
            completion(.failure(.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                print("---> data: \n \((String(data: data, encoding: .utf8) ?? "nil") as String) \n")
                let decodedResponse = try JSONDecoder().decode(APIResponse<EmptyCodable>.self, from: data)
                if decodedResponse.message == "Success!" {
                    completion(.success(()))
                } else {
                    completion(.failure(.serverError(decodedResponse.message)))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    static func addGuest(authUser: AuthUser, guestName: String, partyCode: String, atParty: Int, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let url = URL(string: "https://xt1sdav9qk.execute-api.us-east-1.amazonaws.com/Prod/hello") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(authUser.idToken, forHTTPHeaderField: "AccessToken")

        let guestToAdd = Guest(
            username: authUser.username,
            guest_name: guestName,
            party_code: partyCode,
            at_party: atParty
        )

        do {
            request.httpBody = try JSONEncoder().encode(guestToAdd)
        } catch {
            completion(.failure(.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            do {
                print("---> data: \n \((String(data: data, encoding: .utf8) ?? "nil") as String) \n")
                let decodedResponse = try JSONDecoder().decode(APIResponse<EmptyCodable>.self, from: data)
                if decodedResponse.message == "Success!" {
                    completion(.success(()))
                } else {
                    completion(.failure(.serverError(decodedResponse.message)))
                }
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
