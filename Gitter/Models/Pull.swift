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
        
        let urlString = "https://api.github.com/repos/\(repo.fullName)/pulls?per_page=100&state=open"
        
        GitHub().get(urlString: urlString) { result in
            self.complete {
                try result.map { response in
                    try response
                        .decoding([GitPullShape].self)
                        .map { Pull(repo: repo, shape: $0) }
                }
            }
        }
    }
    
}
