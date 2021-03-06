//
//  Pull.swift
//  Gitter
//
//  Created by Greg Fajen on 3/4/21.
//

import Foundation

class Pull {
    
    let repo: Repo
    let shape: GitPullShape
    
    lazy var filesResource = FilesResource(self)
    
    init(repo: Repo, shape: GitPullShape) {
        self.repo = repo
        self.shape = shape
    }
    
    var number: Int { shape.number }
    
}

typealias PullsResource = Resource<[Pull]>

extension PullsResource {
    
    convenience init(_ repo: Repo) {
        self.init()
        
        GitHub().get(urlString: "https://api.github.com/repos/\(repo.fullName)/pulls") { result in
            let pulls = result.map { response in
                response
                    .decoding([GitPullShape].self)
                    .map { Pull(repo: repo, shape: $0) }
            }
            
            self.complete(with: pulls)
        }
    }
    
}
