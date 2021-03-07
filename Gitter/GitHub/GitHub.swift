//
//  GitHub.swift
//  Gitter
//
//  Created by Greg Fajen on 3/3/21.
//

import Foundation

struct GitHub {
    
    func get(url: URL,
             parameters: [String:String] = [:],
             completion: @escaping (Result<Response, Error>) -> ()) {
        var request = URLRequest(url: url)
        request.addValue("token \(gitHubAuthorizationToken)", forHTTPHeaderField: "Authorization")
        
        for (key, value) in parameters {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    let error = GitterError.missingResponse
                    completion(.failure(error))
                    return
                }
                
                if response.statusCode >= 400 {
                    let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any]
                    var message = json?["message"] as? String ?? "Something went wrong"
                    
                    if message == "Bad credentials", gitHubAuthorizationToken.isEmpty {
                        message = "Bad credentials.\nDouble-check your token in 'AuthorizationToken.swift'"
                    }
                    
                    let error = GitterError.serverError(response.statusCode, message)
                    completion(.failure(error))
                    return
                }
                
                completion(.success(Response(data: data, urlResponse: response)))
            }
        }
        
        task.resume()
    }
    
    func get(urlString: String,
             parameters: [String:String] = [:],
             completion: @escaping (Result<Response, Error>) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(.failure(GitterError.invalidURL))
            return
        }
        
        get(url: url, parameters: parameters, completion: completion)
    }
    
}

struct Response {
    
    let data: Data
    let urlResponse: HTTPURLResponse
    
    var string: String {
        String(data: data, encoding: .utf8) ?? ""
    }
    
    func decoding<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: data)
    }
    
}
