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
            print(String(describing: data))
            print(String(describing: response))
            print(String(describing: error))
            print("")
            
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let response = response else {
                    #warning("fix me")
                    fatalError()
                }
                
                completion(.success(Response(data: data, urlResponse: response)))
            }
            
        }
        
        task.resume()
    }
    
    func get(urlString: String,
             completion: @escaping (Result<Response, Error>) -> ()) {
        guard let url = URL(string: urlString) else {
            #warning("fix me")
            fatalError()
        }
        
        get(url: url, completion: completion)
    }
    
}

@available(*, deprecated)
extension GitHub {
    
    func getRepo() {
        get(urlString: "https://api.github.com/repos/octocat/hello-world") { result in
            let repo = result.success!.decoding(GitRepoShape.self)
            
            let json = try! JSONSerialization.jsonObject(with: result.success!.data, options: []) as! [String:Any]
            print(json)
            print("")
        }
    }
    
    func getPulls(completion: @escaping (Result<[GitPullShape], Error>) -> ()) {
        get(urlString: "https://api.github.com/repos/octocat/hello-world/pulls") { result in
            print(result)
            switch result {
                case .success(let response):
                    let pulls = response.decoding([GitPullShape].self)
                    //                    let json = try! JSONSerialization.jsonObject(with: response.data, options: []) as! [[String:Any]]
                    completion(.success(pulls))
                    
                case .failure:
                    #warning("fix me")
                    fatalError()
            }
        }
    }
    
    func tempLoadFile(_ file: GitFileShape, commit: String) -> String {
        let urlString = "https://api.github.com/repos/octocat/hello-world/contents/\(file.filename)?ref=\(commit)"
        let data = try! Data(contentsOf: URL(string: urlString)!, options: [])
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
        let content = (json["content"] as! String).replacingOccurrences(of: "\n", with: "")
        let decoded = Data(base64Encoded: content)!
        let string = String(data: decoded, encoding: .utf8)!
        return string
    }
    
    func getFiles() {
        getPulls { result in
            let pull = result.success![1]
            let base = pull.base.sha
            let head = pull.head.sha
            
            get(urlString: "https://api.github.com/repos/octocat/hello-world/pulls/\(pull.number)/files") { result in
                let response = result.success!
                let json = try! JSONSerialization.jsonObject(with: response.data, options: []) as! [[String:Any]]
                
                let files = response.decoding([GitFileShape].self)
                let file = files.first!
                
                let before = tempLoadFile(file, commit: base)
                let after = tempLoadFile(file, commit: head)
                
                print(files)
                print(before.components(separatedBy: "\n").count)
                print(after.components(separatedBy: "\n").count)
                print("")
            }
        }
    }
    
}

struct Response {
    
    let data: Data
    let urlResponse: URLResponse
    
    var string: String {
        String(data: data, encoding: .utf8) ?? ""
    }
    
    func decoding<T: Decodable>(_ type: T.Type) -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print(error)
            #warning("fix me")
            fatalError()
        }
    }
    
}
