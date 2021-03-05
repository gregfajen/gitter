//
//  GitHubShapes.swift
//  Gitter
//
//  Created by Greg Fajen on 3/4/21.
//

import Foundation

struct GitRepoShape: Codable {
    
    let name: String
    let description: String
    let full_name: String
    
}

struct GitPullShape: Codable {
    
    let number: Int
    let state: String
    let title: String
    let body: String
    let labels: [GitLabelShape]
    
    let user: GitUserShape
    let head: GitCommitShape
    let base: GitCommitShape
    
}

struct GitCommitShape: Codable {
    
    let label: String
    let ref: String
    let sha: String
    
}

struct GitLabelShape: Codable {
    
    let name: String
    let color: String
    
}

struct GitUserShape: Codable {
    
    let login: String
    let avatar_url: String
    
}

struct GitFileShape: Codable {
    
    let sha: String
    let filename: String
    let status: String
    let additions: Int
    let deletions: Int
    let changes: Int
    
}
