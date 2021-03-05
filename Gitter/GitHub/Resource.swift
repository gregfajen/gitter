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
    
    // MARK: Observing
    
    func whenComplete(_ completion: @escaping Completion) {
        dispatchPrecondition(condition: .onQueue(.main)) // let's stay single-threaded for now
        
        if let result = self.result {
            completion(result)
            return
        }
        
        completions.append(completion)
    }
    
    func whenSuccess(_ completion: @escaping (Value) -> ()) {
        whenComplete {
            if let value = $0.success {
                completion(value)
            }
        }
    }
    
    func whenFailure(_ completion: @escaping (Error) -> ()) {
        whenComplete {
            if let error = $0.error {
                completion(error)
            }
        }
    }
    
    // MARK: Completing
    
    func complete(with result: Result<Value, Error>) {
        dispatchPrecondition(condition: .onQueue(.main)) // let's stay single-threaded for now
        if self.result.exists { return }
        self.result = result
        
        for completion in completions {
            completion(result)
        }
        
        completions = []
    }
    
    func complete(with closure: () throws -> Value) {
        do {
            succeed(with: try closure())
        } catch {
            fail(with: error)
        }
    }
    
    func succeed(with value: Value) {
        complete(with: .success(value))
    }
    
    func fail(with error: Error) {
        complete(with: .failure(error))
    }
    
    func cascade(to resource: Resource<Value>) {
        whenComplete { result in
            resource.complete(with: result)
        }
    }
    
    // MARK: Convenience
    
    var isComplete: Bool { result.exists }
    var value: Value? { result?.success }
    var error: Error? { result?.error }
    
    var status: Status {
        switch result {
            case .none: return .loading
            case .some(.success(let value)): return .loaded(value)
            case .some(.failure(let error)): return .error(error)
        }
    }
    
    enum Status {
        case loading
        case loaded(Value)
        case error(Error)
    }
    
}

extension Result {
    
    var success: Success? {
        switch self {
            case .success(let success):
                return success
                
            case .failure:
                return nil
        }
    }
    
    var error: Error? {
        switch self {
            case .success:
                return nil
                
            case .failure(let error):
                return error
        }
    }
    
}

extension Optional {
    
    var exists: Bool {
        self != nil
    }
    
    func unwrap(orThrow error: @autoclosure () -> Error) throws -> Wrapped {
        guard let value = self else {
            throw error()
        }
        
        return value
    }
    
}
