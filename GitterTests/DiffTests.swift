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
        
        let changes = diff(old: old, new: new)
        
        XCTAssert(changes.count == 1)
        
        guard case let .some(.equal(sourceLines, targetLines)) = changes.first else {
            XCTFail()
            return
        }
        
        XCTAssert(sourceLines == 0...2)
        XCTAssert(targetLines == 0...2)
    }
    
    
    func diff(old: String, new: String) -> [MyersDiff.Change] {
        MyersDiff.diff(a: old.components(separatedBy: .newlines),
                       b: new.components(separatedBy: .newlines))
    }
    
}
