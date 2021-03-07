//
//  DiffSectionTests.swift
//  GitterTests
//
//  Created by Greg Fajen on 3/6/21.
//

import XCTest
@testable import Gitter

class DiffSectionTests: XCTestCase {
    
    var hunk: Hunk {
        Hunk(changes: [
            .equal(sourceLines: 0...2, targetLines: 0...2),
            .remove(sourceLine: 3),
            .insert(targetLine: 3),
            .equal(sourceLines: 4...6, targetLines: 4...6)
        ])
    }
    
    func testLines() {
        let section = DiffSection(hunk)
        XCTAssert(section.pairs.count == 7)
        
        let pair = section.pairs[3]
        XCTAssert(pair.old == .remove(3))
        XCTAssert(pair.new == .insert(3))
    }
    
    func testRanges() {
        let section = DiffSection(hunk)
        XCTAssert(section.oldLineRange == 0...6)
        XCTAssert(section.newLineRange == 0...6)
    }
    
}
