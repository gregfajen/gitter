//
//  Diff+Myers.swift
//  Gitter
//
//  Created by Greg Fajen on 3/5/21.
//

import Foundation

// Implementation of Eugene W. Myers' Diff Algorithm
// "An O(ND) Difference Algorithm and Its Variations"
// http://www.xmailserver.org/diff2.pdf
//
// with much help from
// https://blog.jcoglan.com/2017/02/12/the-myers-diff-algorithm-part-1/
//
// Myers' Diff is the default algorithm in Git

/// A namespace for generating diffs
struct MyersDiff {
    
    public enum Change: Equatable {
        case remove(sourceLine: Int)
        case insert(targetLine: Int)
        case equal(sourceLines: ClosedRange<Int>, targetLines: ClosedRange<Int>)
    }
    
    // A temporary internal representation
    internal struct Move: CustomDebugStringConvertible {
        let x₋₁, y₋₁, x, y: Int
        
        var debugDescription: String {
            "(\(x₋₁), \(y₋₁)) -> (\(x), \(y))"
        }
        
    }
    
    /// Generate a diff between two sequences.
    ///
    ///  - Parameters:
    ///    - old: The old sequence
    ///    - new: The new sequence
    ///
    ///  - Returns: A list of `Changes` representing a diff that describes how to transform a
    ///             source sequence (`old`) into a target sequence (`new`).
    static func diff<Element: Equatable>(_ old: [Element], _ new: [Element]) -> [Change] {
        if old.isEmpty, new.isEmpty { return [] }
        return backtrack(old, new).asChanges
    }
    
    /// Goes backwards through the endpoints generated in `getTrace` to produce a
    /// lighter and more convenient representation.
    ///
    ///  - Parameters:
    ///    - a: The old sequence
    ///    - b: The new sequence
    ///
    ///  - Returns: A list of `Moves` representing the optimal path through the edit graph
    static func backtrack<Element: Equatable>(_ a: [Element], _ b: [Element]) -> [Move] {
        var x = a.count
        var y = b.count
        
        var changes = [Move]()
        
        for (d, V) in getTrace(a, b).lazy.enumerated().reversed() {
            let k = x - y
            
            let k₋₁: Int
            if k == -d || (k != d && V[k - 1] < V[k + 1]) {
                k₋₁ = k + 1
            } else {
                k₋₁ = k - 1
            }
            
            let x₋₁ = V[k₋₁]
            let y₋₁ = x₋₁ - k₋₁
            
            while x > x₋₁, y > y₋₁ {
                changes.append(Move(x₋₁: x - 1,
                                    y₋₁: y - 1,
                                    x: x,
                                    y: y))
                x -= 1
                y -= 1
            }
            
            if d > 0 {
                changes.append(Move(x₋₁: x₋₁, y₋₁: y₋₁, x: x, y: y))
            }
            
            x = x₋₁
            y = y₋₁
        }
        
        return changes.reversed()
    }
    
    /// Determines an optimal path through the edit graph of the diff
    ///
    ///  - Parameters:
    ///    - a: The old sequence
    ///    - b: The new sequence
    ///
    ///  - Returns: A list of the furthest endpoints reached at each iteration
    ///
    ///  - Note: Currently, `OffsetArray` is somewhat wasteful in memory (requires (N+M)^2 * 8 bytes)
    ///          it could be made more memory efficient at the cost of some speed
    ///          by either making `OffsetArray` as a sparse array (built using a Dictionary)
    ///          or by implementing some of the refinements mentioned in the paper
    static func getTrace<Element: Equatable>(_ a: [Element], _ b: [Element]) -> [OffsetArray<Int>] {
        let N = a.count
        let M = b.count
        let MAX = N + M
        
        var V = OffsetArray(repeating: 0, range: -MAX...MAX)
        var trace = [OffsetArray<Int>]()
        
        for D in 0...MAX {
            trace.append(V)
            
            for k in stride(from: -D, through: D, by: 2) {
                var x: Int
                if k == -D || (k != D && V[k-1]<V[k+1]) {
                    x = V[k+1]
                } else {
                    x = V[k-1]+1
                }
                
                var y = x - k
                
                while x < N, y < M, a[x] == b[y] {
                    x += 1
                    y += 1
                }
                
                V[k] = x
                
                if x >= N, y >= M {
                    return trace
                }
            }
        }
        
        // theoretically unreachable
        fatalError()
    }
    
}

// convenience array which allows negative indices
struct OffsetArray<Element> {
    
    let offset: Int
    var array: [Element]
    
    init(repeating value: Element, range: ClosedRange<Int>) {
        offset = -range.lowerBound
        array = [Element](repeating: value, count: range.count)
    }
    
    subscript(i: Int) -> Element {
        get { array[i+offset] }
        set { array[i+offset] = newValue }
    }
    
}

extension Sequence where Element == MyersDiff.Move {
    
    /// Simplifies a list of `Move`s, an internal representation, into `Change`s, which is the
    /// interface we would like to expose.
    ///
    ///  - Returns: A list of `Changes` representing a diff that describes how to transform a
    ///             source sequence into a target sequence.
    var asChanges: [MyersDiff.Change] {
        var changes = [MyersDiff.Change]()
        
        for move in self {
            if move.x == move.x₋₁ {
                changes.append(.insert(targetLine: move.y₋₁))
            } else if move.y == move.y₋₁ {
                changes.append(.remove(sourceLine: move.x₋₁))
            } else {
                let sourceLine = move.x₋₁
                let targetLine = move.y₋₁
                if case let .equal(sourceLines, targetLines) = changes.last {
                    changes.removeLast()
                    changes.append(.equal(sourceLines: sourceLines.lowerBound...sourceLine,
                                          targetLines: targetLines.lowerBound...targetLine))
                } else {
                    changes.append(.equal(sourceLines: sourceLine...sourceLine,
                                          targetLines: targetLine...targetLine))
                }
            }
        }
        
        return changes
    }
    
}
