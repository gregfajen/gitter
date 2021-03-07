//
//  GitHub.swift
//  Gitter
//
//  Created by Greg Fajen on 3/3/21.
//

import Foundation

#warning("temporary, don't hardcode long term")
let token = "2e3407cc33caffcbd5a093535ac42d1244b779be"

struct GitHub {
    
    func get(url: URL,
             completion: @escaping (Result<Response, Error>) -> ()) {
        var request = URLRequest(url: url)
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let response = response else {
                    let error = GitterError.missingResponse
                    completion(.failure(error))
                    return
                }
                
                completion(.success(Response(data: data, urlResponse: response as! HTTPURLResponse)))
            }
        }
        
        task.resume()
    }
    
    func get(urlString: String,
             completion: @escaping (Result<Response, Error>) -> ()) {
        guard let url = URL(string: urlString) else {
            completion(.failure(GitterError.invalidURL))
            return
        }
        
        get(url: url, completion: completion)
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
