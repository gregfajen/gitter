//
//  HunkTests.swift
//  GitterTests
//
//  Created by Greg Fajen on 3/6/21.
//

import XCTest
@testable import Gitter

class HunkTests: XCTestCase {
    
    func testIndices() {
        let array = ["a", "b", "c"]
        let indices = array.indices { $0 != "a" }
        XCTAssert(indices == [1, 2])
    }
    
    func testHasChanges() {
        XCTAssert(Hunk(changes: [.insert(targetLine: 0)]).hasChanges)
        XCTAssert(Hunk(changes: [.remove(sourceLine: 0)]).hasChanges)
        
        XCTAssert(!Hunk(changes: [.equal(sourceLines: 0...1, targetLines: 0...1)]).hasChanges)
    }
    
    func testTrim() {
        let hunk = Hunk(changes: [
            .equal(sourceLines: 0...20, targetLines: 0...20),
            .remove(sourceLine: 21),
            .insert(targetLine: 21),
            .equal(sourceLines: 22...40, targetLines: 22...40)
        ])
        
        let trimmed = hunk.trimmingContext(3)
        
        guard case let .equal(firstOld, firstNew) = trimmed.changes.first else {
            XCTFail()
            return
        }
        
        guard case let .equal(lastOld, lastNew) = trimmed.changes.last else {
            XCTFail()
            return
        }
        
        XCTAssert(firstOld == 18...20)
        XCTAssert(firstNew == 18...20)
        
        XCTAssert(lastOld == 22...24)
        XCTAssert(lastNew == 22...24)
    }
    
    func testHunked() {
        let changes: [MyersDiff.Change] = [
            .insert(targetLine: 0),
            .remove(sourceLine: 0),
            .equal(sourceLines: 1...20, targetLines: 1...20),
            .insert(targetLine: 1)
        ]
        
        let hunks = changes.hunked(3)
        XCTAssert(hunks.count == 2)
        
        guard case let .equal(firstContext, _) = hunks.first?.changes.last else {
            XCTFail()
            return
        }
        
        guard case let .equal(lastContext, _) = hunks.last?.changes.first else {
            XCTFail()
            return
        }
        
        XCTAssert(firstContext == 1...3)
        XCTAssert(lastContext == 18...20)
    }
    
}
