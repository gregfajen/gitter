//
//  Repo.swift
//  Gitter
//
//  Created by Greg Fajen on 3/4/21.
//

import Foundation

class Repo {
    
    let shape: GitRepoShape
    
    lazy var pulls = PullsResource(self)
    
    init(_ shape: GitRepoShape) {
        self.shape = shape
    }
    
    var fullName: String { shape.full_name }
    var name: String { shape.name }
    var description: String { shape.description }
    
}

typealias RepoResource = Resource<Repo>

extension RepoResource {
    
    convenience init(fullName: String) {
        self.init()
        
        GitHub().get(urlString: "https://api.github.com/repos/\(fullName)") { result in
            switch result {
                case .success(let response):
                    self.succeed {
                        let shape = try response.decoding(GitRepoShape.self)
                        return Repo(shape)
                    }
                    
                case .failure(let error):
                    self.fail(with: error)
            }
        }
    }
    
    var pulls: PullsResource {
        let resource = PullsResource()
        
        whenComplete {
            switch $0 {
                case .success(let repo):
                    repo.pulls.cascade(to: resource)
                    
                case .failure(let error):
                    resource.fail(with: error)
            }
        }
        
        return resource
    }
    
}
