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

struct MyersDiff {
    
    struct Element {
        
    }
    
    static func diff(a: [String], b: [String]) -> [Change] {
        let changes = self.changes(a: a, b: b)
        
        print("source: \(a.joined(separator: ""))")
        print("target: \(b.joined(separator: ""))")
        
        for change in changes {
            switch change {
                case .remove(let sourceLine):
                    let line = a[sourceLine]
                    print(" - \(line)")
                case .insert(let targetLine):
                    let line = b[targetLine]
                    print(" + \(line)")
                case .equal(let sourceLines, _):
                    for sourceLine in sourceLines {
                        let line = a[sourceLine]
                        print("   \(line)")
                    }
            }
        }
        
        return changes
    }
    
    // temp function to get closer to desired form for unit testing
    static func changes(a: [String], b: [String]) -> [Change] {
        var changes = [Change]()
        
        for old in oldChanges(a: a, b: b) {
            if case let .equal(sourceLines, targetLines) = changes.last,
               case let .equal(nextSourceLine, nextTargetLine) = old {
                changes.removeLast()
                changes.append(Change.equal(sourceLines: sourceLines.lowerBound...nextSourceLine,
                                            targetLines: targetLines.lowerBound...nextTargetLine))
            } else {
                changes.append(Change(old))
            }
        }
        
        return changes
    }
    
    static func oldChanges(a: [String], b: [String]) -> [TempChange] {
        let changes = backtrack(a: a, b: b).reversed().compactMap { move -> TempChange? in
            
            print(move)
            
            //            let a_line = a[move.prev_x]
            //            let b_line = b[move.prev_y]
            
            if move.x == move.prev_x {
                return .insert(targetLine: move.prev_y)
            } else if move.y == move.prev_y {
                return .remove(sourceLine: move.prev_x)
            } else {
                return .equal(sourceLine: move.prev_x, targetLine: move.prev_y)
            }
            
            return nil
        }
        
        return changes
    }
    
    enum Change: Equatable {
        case remove(sourceLine: Int)
        case insert(targetLine: Int)
        case equal(sourceLines: ClosedRange<Int>, targetLines: ClosedRange<Int>)
        
        init(_ old: TempChange) {
            switch old {
                case .remove(let sourceLine):
                    self = .remove(sourceLine: sourceLine)
                case .insert(let targetLine):
                    self = .insert(targetLine: targetLine)
                case .equal(let sourceLine, let targetLine):
                    self = .equal(sourceLines: sourceLine...sourceLine,
                                  targetLines: targetLine...targetLine)
            }
        }
    }
    
    enum TempChange {
        case remove(sourceLine: Int)
        case insert(targetLine: Int)
        case equal(sourceLine: Int, targetLine: Int)
    }
    
    struct TempMove: CustomDebugStringConvertible {
        let prev_x, prev_y, x, y: Int
        
        var debugDescription: String {
            "(\(prev_x), \(prev_y)) -> (\(x), \(y))"
        }
    }
    
    static func backtrack(a: [String], b: [String]) -> [TempMove] {
        let traces = self.traces(a: a, b: b)
        var x = a.count
        var y = b.count
        
        var moves = [TempMove]()
        
        for (d, V) in traces.enumerated().reversed() {
            let k = x - y
            
            let prev_k: Int
            if k == -d || (k != d && V[k - 1] < V[k + 1]) {
                prev_k = k + 1
            } else {
                prev_k = k - 1
            }
            
            let prev_x = V[prev_k]
            let prev_y = prev_x - prev_k
            
            while x > prev_x, y > prev_y {
                let move = TempMove(prev_x: x - 1, prev_y: y - 1, x: x, y: y)
                print(move)
                moves.append(move)
//            yield x - 1, y - 1, x, y
                    x -= 1
                    y -= 1
            }
            
            if d > 0 {
                let move = TempMove(prev_x: prev_x, prev_y: prev_y, x: x, y: y)
                print(move)
                moves.append(move)
            }
            
            x = prev_x
            y = prev_y
        }
        
        return moves
    }
    
    static func traces(a: [String], b: [String]) -> [OffsetArray<Int>] {
        let N = a.count
        let M = b.count
        let MAX = N + M
        
        let Z = 2 * min(N, M) + 2
        
        var V = OffsetArray(repeating: Int.min, range: -MAX...MAX)
        var Vs = [OffsetArray<Int>]()
        
        V[1] = 0
        
        for D in 0...MAX {
            Vs.append(V)
            
            for k in stride(from: -D, through: D, by: 2) {
                print("D: \(D), k: \(k)")
                print("    V[\(k)]: \(V[k])")
                var x: Int
                if k == -D {
                    print("    go right")
                    x = V[k+1]
                    precondition((x-k) >= 0)
                } else if k == D {
                    print("    go down")
                    x = V[k-1]+1
                    precondition((x-k) >= 0)
                } else {
                    if V[k-1]<V[k+1] {
                        print("    go right")
                        x = V[k+1]
                        precondition((x-k) >= 0)
                    } else {
                        print("    go down")
                        x = V[k-1]+1
                        precondition((x-k) >= 0)
                    }
                }
                
                var y = x - k
                
                print("    (x, y): (\(x), \(y))")
                
                while x < N, y < M, a[x] == b[y] {
                    print("    diagonal (a[\(x)] = b[\(y)] = \(a[x]))")
                    x += 1
                    y += 1
                }
                
                V[k] = x
                print("    V[\(k)] := \(x)")
                
                if x >= N, y >= M {
                    // Length of an SES is D
                    return Vs
                }
            }
        }
        
        // theoretically unreachable
        fatalError()
    }
    
}

// convenience array which allows negative indices
struct OffsetArray<Element>: Sequence {
    
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
    
    __consuming func makeIterator() -> Array<Element>.Iterator {
        array.makeIterator()
    }
    
}
