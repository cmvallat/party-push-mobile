//
//  AuthUser.swift
//  Song_Requester
//
//  Created by Christian Vallat on 8/6/24.
//

import Foundation
import Observation

@Observable
class AuthUser {
    var email: String = ""
    var username: String = ""
    var password: String = ""
    var accessToken: String = ""
    var idToken: String = ""
    var refreshToken: String = ""

    func saveTokensToKeychain() {
        KeychainHelper.shared.save(accessToken, forKey: Self.kAccessToken)
        KeychainHelper.shared.save(idToken, forKey: Self.kIdToken)
        KeychainHelper.shared.save(refreshToken, forKey: Self.kRefreshToken)
    }
    
    func loadTokensFromKeychain() {
        accessToken = KeychainHelper.shared.get(forKey: Self.kAccessToken) ?? ""
        idToken = KeychainHelper.shared.get(forKey: Self.kIdToken) ?? ""
        refreshToken = KeychainHelper.shared.get(forKey: Self.kRefreshToken) ?? ""
    }
    
    func deleteTokensFromKeychain() {
        KeychainHelper.shared.delete(forKey: Self.kAccessToken)
        KeychainHelper.shared.delete(forKey: Self.kIdToken)
        KeychainHelper.shared.delete(forKey: Self.kRefreshToken)
        accessToken = ""
        idToken = ""
        refreshToken = ""
    }
}

extension AuthUser {
    static let kAccessToken = "accessToken"
    static let kIdToken = "idToken"
    static let kRefreshToken = "refreshToken"
    
    // Decode JWT payload
    static func decodeJWTPayload(_ jwt: String) -> [String: Any]? {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        var base64String = segments[1]
        let requiredLength = (4 - base64String.count % 4) % 4
        if requiredLength > 0 {
            base64String += String(repeating: "=", count: requiredLength)
        }
        guard let data = Data(base64Encoded: base64String, options: [.ignoreUnknownCharacters]),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    // Extract username from token
    static func extractUsername(from jwt: String) -> String? {
        guard let payload = decodeJWTPayload(jwt) else { return nil }
        return (payload["cognito:username"] as? String) ?? (payload["username"] as? String)
    }
    
    // Check if JWT is expired
    static func isJWTExpired(_ jwt: String) -> Bool {
        guard let payload = decodeJWTPayload(jwt),
              let exp = payload["exp"] as? TimeInterval else { return true }
        let expiryDate = Date(timeIntervalSince1970: exp)
        return expiryDate <= Date()
    }
    
    // Loads tokens, checks validity, and sets username. Returns true if valid and not expired.
    func loadTokensAndValidate() -> Bool {
        loadTokensFromKeychain()
        guard !accessToken.isEmpty, !Self.isJWTExpired(accessToken) else {
            return false
        }
        
        // Set the username from the access token, fallback to id token
        if let foundUsername = Self.extractUsername(from: accessToken) {
            self.username = foundUsername
        } else if let foundUsername = Self.extractUsername(from: idToken) {
            self.username = foundUsername
        }
        
        // If username could not be found, validation fails because we need it for logic
        guard !self.username.isEmpty else {
            return false
        }
        
        return true
    }
}
