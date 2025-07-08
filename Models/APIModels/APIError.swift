//
//  APIError.swift
//  PartyPushMobileApp
//
//  Created by Christian Vallat on 4/25/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case noData
    case decodingError
    case serverError(String)  // e.g. error message from backend

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .encodingError:
            return "Failed to encode request data."
        case .noData:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode the response."
        case .serverError(let message):
            return message
        }
    }
}
