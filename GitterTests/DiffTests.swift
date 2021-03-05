//
//  DiffTests.swift
//  GitterTests
//
//  Created by Greg Fajen on 3/5/21.
//

import XCTest
@testable import Gitter

class DiffTests: XCTestCase {
    
    func testSame() {
        let old = """
        a
        b
        c
        """
        
        let new = """
        a
        b
        c
        """
        
        let changes = diff(old, new)
        
        XCTAssert(changes.count == 1)
        
        guard case let .some(.equal(sourceLines, targetLines)) = changes.first else {
            XCTFail()
            return
        }
        
        XCTAssert(sourceLines == 0...2)
        XCTAssert(targetLines == 0...2)
    }
    
    func testDelete() {
        let old = """
        a
        """
        
        let new = ""
        
        let changes = diff(old, new)
        
        XCTAssert(changes.count == 1)
        
        guard case let .some(.remove(sourceLine)) = changes.first else {
            XCTFail()
            return
        }
        
        XCTAssert(sourceLine == 0)
    }
    
    func testInsert() {
        let old = ""
        
        let new = """
        a
        """
        
        let changes = diff(old, new)
        
        XCTAssert(changes.count == 1)
        
        guard case let .some(.insert(targetLine)) = changes.first else {
            XCTFail()
            return
        }
        
        XCTAssert(targetLine == 0)
    }
    
    // from Myers' paper: http://www.xmailserver.org/diff2.pdf
    func testPaperExample() {
        let old = """
        A
        B
        C
        A
        B
        B
        A
        """
        
        let new = """
        C
        B
        A
        B
        A
        C
        """
        
        let result = diff(old, new)
        let expected: [MyersDiff.Change] = [
            .remove(sourceLine: 0),
            .remove(sourceLine: 1),
            .equal(sourceLines: 2...2, targetLines: 0...0),
            .insert(targetLine: 1),
            .equal(sourceLines: 3...4, targetLines: 2...3),
            .remove(sourceLine: 5),
            .equal(sourceLines: 6...6, targetLines: 4...4),
            .insert(targetLine: 5)
        ]
        
        assertEqual(result, expected)
    }
    
    func diff(_ old: String, _ new: String) -> [MyersDiff.Change] {
        func asLines(_ string: String) -> [String] {
            if string.isEmpty {
                return []
            } else {
                return string.components(separatedBy: .newlines)
            }
        }
        
        return MyersDiff.diff(asLines(old),
                              asLines(new))
    }
    
    func assertEqual(_ result: [MyersDiff.Change], _ expected: [MyersDiff.Change]) {
        XCTAssert(result.count == expected.count)
        
        for (i, (r, e)) in zip(result, expected).enumerated() {
            if r == e { continue }
            
            print("Failure at index \(i): Expected \(e), found \(r)")
            XCTFail()
        }
    }
    
}
