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
    
    var status: Status { Status(rawValue: shape.status) ?? .unknown }
    
    enum Status: String {
        case renamed, modified, added, removed, unknown
    }
    
    lazy var beforeResource: Resource<[String]> = makeBeforeResource()
    lazy var afterResource: Resource<[String]> = makeAfterResource()
    lazy var diffResource = beforeResource.and(afterResource).map(Diff.init)
    
    init(pull: Pull, shape: GitFileShape) {
        self.pull = pull
        self.shape = shape
    }
    
    var filename: String { shape.filename }
    
    var emptyResource: Resource<[String]> {
        let resource = Resource<[String]>()
        resource.succeed(with: [])
        return resource
    }
    
    func makeBeforeResource() -> Resource<[String]> {
        if status == .added {
            return emptyResource
        } else {
            return resource(for: pull.shape.base.sha)
        }
    }
    
    func makeAfterResource() -> Resource<[String]> {
        if status == .removed {
            return emptyResource
        } else {
            return resource(for: pull.shape.head.sha)
        }
    }
    
    func resource(for commit: String) -> Resource<[String]> {
        let resource = Resource<[String]>()
        let urlString = "https://raw.githubusercontent.com/\(pull.repo.fullName)/\(commit)/\(filename.escaped)"
        
        GitHub().get(urlString: urlString) { result in
            switch result {
                case .success(let response):
                    resource.succeed {
                        guard response.urlResponse.statusCode == 200 else {
                            return []
                        }
                        
                        if let string = String(data: response.data, encoding: .utf8) {
                            var lines = string
                                .replacingOccurrences(of: "\r", with: "")
                                .components(separatedBy: "\n")
                            while let last = lines.last, last.isEmpty {
                                lines.removeLast()
                            }
                            return lines
                        } else {
                            return []
                        }
                    }
                    
                case .failure(let error):
                    resource.fail(with: error)
            }
        }
        
        return resource.mapError { error -> [String] in
            if case let .serverError(code, _) = (error as? GitterError) {
                if code == 404 {
                    return []
                }
            }
            
            throw error
        }
    }
    
}

typealias FilesResource = Resource<[File]>

extension FilesResource {
    
    convenience init(_ pull: Pull) {
        self.init()
        
        getFiles(pull: pull)
    }
    
    // quick and dirty pagination
    // in a real app we'd ideally show the first page, and potentially
    // only load the rest of the results as needed (ie, when we scroll down)
    func getFiles(pull: Pull, page: Int = 1, previousFiles: [File] = []) {
        let urlString = "https://api.github.com/repos/\(pull.repo.fullName)/pulls/\(pull.number)/files?per_page=100&page=\(page)"
        
        GitHub().get(urlString: urlString) { result in
            do {
                let files = try result.map { response in
                    try response
                        .decoding([GitFileShape].self)
                        .map { File(pull: pull, shape: $0) }
                }.unwrap()
                
                print("PAGE \(page): \(files.count) files")
                if files.count == 100 {
                    self.getFiles(pull: pull, page: page + 1, previousFiles: previousFiles + files)
                } else {
                    self.succeed(with: previousFiles + files)
                }
                
            } catch {
                if previousFiles.isEmpty {
                    self.fail(with: error)
                } else {
                    self.succeed(with: previousFiles)
                }
            }
        }
        
    }
    
}

extension String {
    
    var escaped: String {
        (self as NSString).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self
    }
    
}
