//
//  DiffSection.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import UIKit

/// A representation of a hunk optimized for UI presentation
struct DiffSection {
    
    let pairs: [DiffPair]
    let oldLineRange: ClosedRange<Int>
    let newLineRange: ClosedRange<Int>
    
    init(_ hunk: Hunk) {
        var subhunks = [[MyersDiff.Change]]()
        var currentSubhunk = [MyersDiff.Change]()
        var lastChangeWasEqual = false
        
        for change in hunk.changes {
            let isEqual = change.isEqual
            if lastChangeWasEqual != isEqual, !currentSubhunk.isEmpty {
                subhunks.append(currentSubhunk)
                currentSubhunk = []
            }
            
            currentSubhunk.append(change)
            lastChangeWasEqual = isEqual
        }
        
        subhunks.append(currentSubhunk)
        
        pairs = subhunks.flatMap { subhunk -> [DiffPair] in
            let oldLines = subhunk.flatMap { change -> [DiffLine] in
                switch change {
                    case .insert: return []
                    case .remove(let sourceLine): return [.remove(sourceLine)]
                    case .equal(let sourceLines, _):
                        return sourceLines.map { .unchanged($0) }
                }
            }
            
            let newLines = subhunk.flatMap { change -> [DiffLine] in
                switch change {
                    case .insert(let targetLine): return [.insert(targetLine)]
                    case .remove: return []
                    case .equal(_, let targetLines):
                        return targetLines.map { .unchanged($0) }
                }
            }
            
            let paddingCount = abs(oldLines.count - newLines.count)
            let padding = [DiffLine](repeating: .none, count: paddingCount)
            
            return zip(oldLines + padding, newLines + padding).map(DiffPair.init)
        }
        
        let oldLineNumbers = pairs.compactMap(\.oldLineNumber)
        oldLineRange = (oldLineNumbers.min() ?? 0) ... (oldLineNumbers.max() ?? 0)
        
        let newLineNumbers = pairs.compactMap(\.newLineNumber)
        newLineRange = (newLineNumbers.min() ?? 0) ... (newLineNumbers.max() ?? 0)
    }
    
}

struct DiffPair {
    let old, new: DiffLine
    
    var oldLineNumber: Int? { old.lineNumber }
    var newLineNumber: Int? { new.lineNumber }
}

enum DiffLine: Equatable {
    case none
    case insert(Int)
    case remove(Int)
    case unchanged(Int)
    
    var lineNumber: Int? {
        switch self {
            case .none: return nil
            case .insert(let lineNumber): return lineNumber
            case .remove(let lineNumber): return lineNumber
            case .unchanged(let lineNumber): return lineNumber
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
            case .none: return UIColor(white: 0.5, alpha: 0.1)
            case .insert: return UIColor.green.withAlphaComponent(0.3)
            case .remove: return UIColor.red.withAlphaComponent(0.3)
            case .unchanged: return .clear
        }
    }
    
    var prefix: String {
        switch self {
            case .none, .unchanged: return ""
            case .insert: return "+"
            case .remove: return "-"
        }
    }
    
}

extension MyersDiff.Change {
    
    var isEqual: Bool {
        switch self {
            case .insert, .remove: return false
            case .equal: return true
        }
    }
    
}
