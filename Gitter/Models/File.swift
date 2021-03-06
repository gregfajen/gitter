//
//  File.swift
//  Gitter
//
//  Created by Greg Fajen on 3/5/21.
//

import Foundation

class File {
    
    let pull: Pull
    let shape: GitFileShape
    
    lazy var beforeResource: Resource<String> = resource(for: pull.shape.base.sha)
    lazy var afterResource: Resource<String>  = resource(for: pull.shape.head.sha)
    lazy var diffResource = beforeResource.and(afterResource).map(Diff.init)
    
    init(pull: Pull, shape: GitFileShape) {
        self.pull = pull
        self.shape = shape
    }
    
    var filename: String { shape.filename }
    
    func resource(for commit: String) -> Resource<String> {
        let resource = Resource<String>()
        let urlString = "https://api.github.com/repos/\(pull.repo.fullName)/contents/\(filename)?ref=\(commit)"
        
        GitHub().get(urlString: urlString) { result in
            switch result {
                case .success(let response):
                    resource.succeed {
                        let json = try JSONSerialization.jsonObject(with: response.data, options: []) as! [String:Any]
                        guard let content = (json["content"] as? String)?.replacingOccurrences(of: "\n", with: "") else {
                            return ""
                        }
                        let decoded = Data(base64Encoded: content)!
                        let string = String(data: decoded, encoding: .utf8)!
                        return string
                    }
                    
                case .failure(let error):
                    resource.fail(with: error)
            }
        }
        
        return resource
//
    }
    
}

typealias FilesResource = Resource<[File]>

extension FilesResource {
    
    convenience init(_ pull: Pull) {
        self.init()
        
        GitHub().get(urlString: "https://api.github.com/repos/\(pull.repo.fullName)/pulls/\(pull.number)/files") { result in
            let result = result.map { response in
                response
                    .decoding([GitFileShape].self)
                    .map { File(pull: pull, shape: $0) }
            }
            
            self.complete(with: result)
        }
    }
    
}
