//
//  ResourceTests.swift
//  GitterTests
//
//  Created by Greg Fajen on 3/6/21.
//

import Foundation

import XCTest
@testable import Gitter

class ResourceTests: XCTestCase {
    
    func testBasic() {
        let expectation = self.expectation(description: "expectation")
        
        let resource = Resource<Int>()
        var result = -1
        
        resource.whenSuccess { value in
            result = value
            expectation.fulfill()
        }
        
        resource.succeed(with: 1)
        
        waitForExpectations(timeout: 1)
        XCTAssert(result == 1)
        XCTAssert(resource.isComplete)
        XCTAssert(resource.status == .loaded(1))
    }
    
    func testBasicFail() {
        let expectation = self.expectation(description: "expectation")
        
        let resource = Resource<Int>()
        var failureCalled = false
        
        resource.whenFailure { _ in
            failureCalled = true
            expectation.fulfill()
        }
        
        resource.fail(with: GitterError.missingResponse)
        
        waitForExpectations(timeout: 1)
        XCTAssert(failureCalled)
        XCTAssert(resource.isComplete)
        XCTAssert(resource.error as? GitterError == .some(.missingResponse))
        XCTAssert(resource.status == .error(GitterError.missingResponse))
    }
    
    func testSetTwice() {
        let expectation = self.expectation(description: "expectation")
        
        let resource = Resource<Int>()
        var result = -1
        
        resource.whenSuccess { value in
            result = value
        }
        
        resource.whenFailure { _ in
            XCTFail()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        
        resource.succeed(with: 1)
        resource.succeed(with: 2)
        resource.fail(with: GitterError.missingResponse)
        
        waitForExpectations(timeout: 1)
        
        XCTAssert(result == 1)
        XCTAssert(resource.value == 1)
    }
    
    func testAnd() {
        let resourceA = Resource<Int>()
        let resourceB = Resource<Int>()
        
        let expectation = self.expectation(description: "expectation")
        var result = -1
        let resource = resourceA.and(resourceB)
        resource.whenSuccess { (a, b) in
            result = a + b
            expectation.fulfill()
        }
        
        resourceA.succeed(with: 2)
        resourceB.succeed(with: 3)
        
        waitForExpectations(timeout: 1)
        
        XCTAssert(result == 5)
        if let value = resource.value {
            XCTAssert(value == (2, 3))
        } else {
            XCTFail()
        }
    }
    
    func testCascade() {
        let resourceA = Resource<Int>()
        let resourceB = Resource<Int>()
        resourceA.cascade(to: resourceB)
        
        let expectation = self.expectation(description: "expectation")
        var result = -1
        resourceB.whenSuccess { value in
            result = value
            expectation.fulfill()
        }
        
        resourceA.succeed(with: 1)
        waitForExpectations(timeout: 1)
        
        XCTAssert(result == 1)
        XCTAssert(resourceA.value == 1)
        XCTAssert(resourceB.value == 1)
    }
    
    func testCompleteWithClosureSuccess() {
        let resource = Resource<Int>()
        
        let expectation = self.expectation(description: "expectation")
        var result = -1
        
        resource.whenSuccess { value in
            result = value
            expectation.fulfill()
        }
        
        resource.complete {
            return .success(1)
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssert(result == 1)
        XCTAssert(resource.value == 1)
    }
    
    func testCompleteWithClosureFailure() {
        let resource = Resource<Int>()
        
        let expectation = self.expectation(description: "expectation")
        var didFail = false
        
        resource.whenFailure { error in
            didFail = true
            expectation.fulfill()
        }
        
        resource.complete {
            throw GitterError.invalidURL
        }
        
        waitForExpectations(timeout: 1)
        
        XCTAssert(didFail)
    }
    
    func testResourceMap() {
        let resourceA = Resource<Int>()
        let resourceB = resourceA.map { $0.isMultiple(of: 3) }
        
        let expectation = self.expectation(description: "expectation")
       
        resourceB.whenSuccess { _ in
            expectation.fulfill()
        }
        
        resourceA.succeed(with: 15)
        waitForExpectations(timeout: 1)
        
        XCTAssert(resourceA.value == 15)
        XCTAssert(resourceB.value == true)
    }
    
}
