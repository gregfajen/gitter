//
//  Hunk.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import Foundation

struct Hunk {
    
    var changes: [MyersDiff.Change]
    
    init <S: Sequence>(changes: S) where S.Element == MyersDiff.Change {
        self.changes = Array(changes)
    }
    
    mutating func trimContext(_ linesOfContext: Int) {
        if case let .equal(sourceLines, targetLines) = changes.first {
            if sourceLines.count > linesOfContext {
                let newSourceLines = (sourceLines.upperBound-linesOfContext+1)...sourceLines.upperBound
                let newTargetLines = (targetLines.upperBound-linesOfContext+1)...targetLines.upperBound
                changes[0] = .equal(sourceLines: newSourceLines, targetLines: newTargetLines)
            }
        }
        
        if case let .equal(sourceLines, targetLines) = changes.last {
            if sourceLines.count > linesOfContext {
                let newSourceLines = sourceLines.lowerBound...(sourceLines.lowerBound+linesOfContext-1)
                let newTargetLines = targetLines.lowerBound...(targetLines.lowerBound+linesOfContext-1)
                changes[changes.count-1] = .equal(sourceLines: newSourceLines, targetLines: newTargetLines)
            }
        }
    }
    
    func trimmingContext(_ linesOfContent: Int) -> Hunk {
        var copy = self
        copy.trimContext(linesOfContent)
        return copy
    }
    
    var hasChanges: Bool {
        changes.contains { change -> Bool in
            switch change {
                case .insert, .remove: return true
                case .equal: return false
            }
        }
    }
    
}

extension Array where Element == MyersDiff.Change {
    
    func hunked(_ linesOfContext: Int = 3) -> [Hunk] {
        func predicate(change: MyersDiff.Change) -> Bool {
            if case let .equal(sourceLines, _) = change {
                return sourceLines.count >= linesOfContext * 2
            } else {
                return false
            }
        }
        
        let indices = self.indices(where: predicate)
        if indices.isEmpty { return [Hunk(changes: self)] }
        
        let lowerBounds = [0] + indices
        let upperBounds = indices + [count-1]
        
        return zip(lowerBounds, upperBounds)
            .map { Hunk(changes: self[$0...$1]) }
            .filter(\.hasChanges)
            .map { $0.trimmingContext(linesOfContext) }
    }
    
}

extension Collection {
    
    func indices(where predicate: (Element) throws -> Bool) rethrows -> [Index] {
        try zip(self, indices) // `enumerated()` returns `Int`s, not `Index`es
            .filter { try predicate($0.0) }
            .map(\.1)
    }
    
}
