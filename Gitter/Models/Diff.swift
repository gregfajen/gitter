//
//  Diff.swift
//  Gitter
//
//  Created by Greg Fajen on 3/5/21.
//

import Foundation

class Diff {
    
    let before: [String]
    let after: [String]
    
    lazy var diff = MyersDiff.diff(before, after)
    lazy var hunks = diff.hunked()
    
    init(before: [String], after: [String]) {
        self.before = before
        self.after = after
    }
    
}
