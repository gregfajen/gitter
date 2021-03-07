//
//  Errors.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import Foundation

enum GitterError: LocalizedError, Equatable {
    
    case serverError(Int, String)
    case missingResponse
    case invalidURL
    
    var errorDescription: String? {
        switch self {
            case .invalidURL: return "Invalid URL"
            case .missingResponse: return "Something went wrong..."
            case .serverError(let code, let message):  return "\(message)\n(Status Code: \(code))"
        }
    }
    
}
