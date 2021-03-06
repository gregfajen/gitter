//
//  HunkView.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import UIKit

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

extension MyersDiff.Change {
    
    var isEqual: Bool {
        switch self {
            case .insert, .remove: return false
            case .equal: return true
        }
    }
    
}

struct DiffPair {
    let old, new: DiffLine
    
    var oldLineNumber: Int? { old.lineNumber }
    var newLineNumber: Int? { new.lineNumber }
}

enum DiffLine {
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
            case .none: return ""
            case .unchanged: return "   "
            case .insert: return " + "
            case .remove: return " - "
        }
    }
    
}

class ChangeCell: UITableViewCell {
    
    let left = ChangeView()
    let right = ChangeView()
    
    var diff: Diff? {
        didSet {
            setNeedsLayout()
        }
    }
    var pair: DiffPair? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        var rect = bounds
        rect.size.width /= 2
        left.diff = diff
        left.line = pair?.old
        left.isNew = false
        left.frame = rect
        left.autoresizingMask = [.flexibleRightMargin, .flexibleWidth, .flexibleHeight]
        addSubview(left)
        
        rect.origin.x += rect.size.width
        right.diff = diff
        right.line = pair?.new
        right.isNew = true
        right.frame = rect
        right.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleHeight]
        addSubview(right)
    }
    
}

class ChangeView: UIView {
    
    var diff: Diff?
    var isNew = false
    var line: DiffLine? {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    var lineNumber: Int? { line?.lineNumber }
    
    override func layoutSubviews() {
        backgroundColor = line?.backgroundColor ?? .clear
    }
    
    override func draw(_ rect: CGRect) {
        attributedString?.draw(with: textRect,
                               options: [.usesLineFragmentOrigin, .usesFontLeading],
                               context: nil)
    }
    
    // MARK: Layout
    
    var margin: CGFloat { 10 }
    
    var lineCountWidth: CGFloat {
        0
    }
    
    var changeX: CGFloat {
        0
    }
    
    var textMargin: CGFloat {
        60
    }
    
    var textRect: CGRect {
        CGRect(x: 30,
               y: 0,
               width: bounds.width - 40,
               height: .greatestFiniteMagnitude)
    }
    
    var desiredHeight: CGFloat {
        let x = attributedString?.boundingRect(with: CGSize(width: textRect.size.width,
                                                            height: .greatestFiniteMagnitude),
                                               options: [.usesLineFragmentOrigin, .usesFontLeading],
                                               context: nil).height ?? 0
        
        return x
    }
    
    // MARK: Text
    
    var font: UIFont { UIFont(name: "Courier", size: 11)! }
    
    var text: String? {
        guard let lineNumber = lineNumber else { return nil }
        
        if isNew {
            return diff?.after[lineNumber]
        } else {
            return diff?.before[lineNumber]
        }
    }
    
    func attributes(color: UIColor, alignment: NSTextAlignment = .left) -> [NSAttributedString.Key:Any] {
        [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: NSParagraphStyle.with(alignment: alignment)
        ]
    }
    
    var attributedString: NSAttributedString? {
        text.map { NSAttributedString(string: $0, attributes: attributes(color: .label)) }
    }
    
}

extension NSParagraphStyle {
    
    static func with(alignment: NSTextAlignment) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        return style
    }
    
}
