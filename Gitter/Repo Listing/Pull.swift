//
//  Pull.swift
//  Gitter
//
//  Created by Greg Fajen on 3/4/21.
//

import Foundation

class Pull {
    
    let shape: GitPullShape
    
    init(_ shape: GitPullShape) {
        self.shape = shape
    }
    
}

typealias PullsResource = Resource<[Pull]>

extension PullsResource {
    
    convenience init(_ repo: Repo) {
        self.init()
        
        GitHub().get(urlString: "https://api.github.com/repos/\(repo.fullName)/pulls") { result in
            let pulls = result.map { response in
                response
                    .decoding([GitPullShape].self)
                    .map { Pull($0) }
            }
            
            self.complete(with: pulls)
        }
    }
    
}
