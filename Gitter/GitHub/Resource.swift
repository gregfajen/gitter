//
//  Resource.swift
//  Gitter
//
//  Created by Greg Fajen on 3/4/21.
//

import Foundation

// kinda like a future or promise but somewhat simplified
class Resource<Value> {
    
    typealias Completion = (Result<Value, Error>) -> ()
    
    var result: Result<Value, Error>?
    private var completions = [Completion]()
    
    func whenComplete(_ completion: @escaping Completion) {
        dispatchPrecondition(condition: .onQueue(.main)) // let's stay single-threaded for now
        
        if let result = self.result {
            completion(result)
            return
        }
        
        completions.append(completion)
    }
    
    func complete(with result: Result<Value, Error>) {
        dispatchPrecondition(condition: .onQueue(.main)) // let's stay single-threaded for now
        if self.result.exists { return }
        self.result = result
        
        for completion in completions {
            completion(result)
        }
        
        completions = []
    }
    
}
