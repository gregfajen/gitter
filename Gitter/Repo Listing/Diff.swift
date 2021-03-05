//
//  Diff.swift
//  Gitter
//
//  Created by Greg Fajen on 3/5/21.
//

import Foundation

class Diff {
    
    let before: String
    let after: String
    
    lazy var diff = MyersDiff.diff(a: before.components(separatedBy: .newlines),
                                   b: after.components(separatedBy: .newlines))
    
    init(before: String, after: String) {
        self.before = before
        self.after = after
    }
    
}
