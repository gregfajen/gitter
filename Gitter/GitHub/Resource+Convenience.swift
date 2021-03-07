//
//  Resource+Convenience.swift
//  Gitter
//
//  Created by Greg Fajen on 3/5/21.
//

import Foundation

extension Resource {
    
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
    
    // MARK: Observation
    
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
    
    // MARK: Completion
    
    func complete(with closure: () throws -> Result<Value, Error>) {
        do {
            complete(with: try closure())
        } catch {
            fail(with: error)
        }
    }
    
    func succeed(with value: Value) {
        complete(with: .success(value))
    }
    
    func succeed(with closure: () throws -> Value) {
        do {
            succeed(with: try closure())
        } catch {
            fail(with: error)
        }
    }
    
    func fail(with error: Error) {
        complete(with: .failure(error))
    }
    
    // MARK: Misc
    
    func cascade(to resource: Resource<Value>) {
        whenComplete { result in
            resource.complete(with: result)
        }
    }
    
    func map<T>(_ closure: @escaping (Value) throws -> T) -> Resource<T> {
        let resource = Resource<T>()
        
        whenComplete { result in
            resource.complete {
                try result.map(closure)
            }
        }
        
        return resource
    }
    
    func mapError(_ closure: @escaping (Error) throws -> Value) -> Resource<Value> {
        let resource = Resource<Value>()
        
        whenComplete { result in
            switch result {
                case .success(let value):
                    resource.succeed(with: value)
                case .failure(let error):
                    resource.succeed { try closure(error) }
            }
        }
        
        return resource
    }
    
    func and<T>(_ other: Resource<T>) -> Resource<(Value, T)> {
        let resource = Resource<(Value, T)>()
        
        // happy path
        func success<T>(ignore: T) {
            if let a = self.value, let b = other.value {
                resource.succeed(with: (a, b))
            }
        }
        
        self.whenSuccess(success)
        other.whenSuccess(success)
        
        // error handling
        func failure(error: Error) {
            resource.fail(with: error)
        }
        
        self.whenFailure(failure)
        other.whenFailure(failure)
        
        return resource
    }
    
}

extension Result {
    
    func map<NewSuccess>(_ transform: (Success) throws -> NewSuccess) throws -> Result<NewSuccess, Failure> {
        switch self {
            case .success(let success):
                return .success(try transform(success))
                
            case .failure(let error):
                return .failure(error)
        }
    }
    
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
    
    func unwrap() throws -> Success {
        switch self {
            case .success(let value): return value
            case .failure(let error): throw error
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

extension Resource.Status: Equatable where Value: Equatable {
    
    static func == (lhs: Resource<Value>.Status, rhs: Resource<Value>.Status) -> Bool {
        switch (lhs, rhs) {
            case (.loading, .loading): return true
            case let (.loaded(l), .loaded(r)): return l == r
            case (.error, .error): return true
            default: return false
        }
    }
    
}
