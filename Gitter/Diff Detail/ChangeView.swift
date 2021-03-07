//
//  ChangeView.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import UIKit

class ChangeView: UIView {
    
    var diff: Diff?
    var isNew = false
    var line: DiffLine? {
        didSet {
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    var lineNumber: Int? { line?.lineNumber } // ZERO-INDEXED
    
    override func layoutSubviews() {
        backgroundColor = line?.backgroundColor ?? .clear
    }
    
    override func draw(_ rect: CGRect) {
        lineNumberString?.draw(with: lineNumberRect,
                               options: [.usesLineFragmentOrigin, .usesFontLeading],
                               context: nil)
        
        changeString?.draw(with: changeRect,
                           options: [.usesLineFragmentOrigin, .usesFontLeading],
                           context: nil)
        
        attributedString?.draw(with: textRect,
                               options: [.usesLineFragmentOrigin, .usesFontLeading],
                               context: nil)
    }
    
    // MARK: Layout
    
    var margin: CGFloat { 10 }
    
    var lineNumberWidth: CGFloat {
        let oldLineCount = diff?.before.count ?? 0
        let newLineCount = diff?.after.count ?? 0
        let maxLineCount = max(oldLineCount, newLineCount)
        let string = NSAttributedString(string: "\(maxLineCount)", attributes: attributes())
        return ceil(string.size().width)
    }
    
    var changeWidth: CGFloat {
        30
    }
    
    var textMargin: CGFloat {
        60
    }
    
    var lineHeightMultiple: CGFloat {
        1.4
    }
    
    var textOffset: CGFloat {
        -2.5
    }
    
    var lineNumberRect: CGRect {
        CGRect(x: margin,
               y: textOffset,
               width: lineNumberWidth,
               height: .greatestFiniteMagnitude)
    }
    
    var changeRect: CGRect {
        CGRect(x: margin + lineNumberWidth,
               y: textOffset,
               width: changeWidth,
               height: .greatestFiniteMagnitude)
    }
    
    var textRect: CGRect {
        let x = margin + lineNumberWidth + changeWidth
        return CGRect(x: x,
                      y: textOffset,
                      width: bounds.width - x - margin,
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
    
    func attributes(color: UIColor = .label,
                    alignment: NSTextAlignment = .left) -> [NSAttributedString.Key:Any] {
        [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: NSParagraphStyle.with(alignment: alignment,
                                                   lineHeightMultiple: lineHeightMultiple)
        ]
    }
    
    var attributedString: NSAttributedString? {
        text.map {
            NSAttributedString(string: $0,
                               attributes: attributes(color: .label))
        }
    }
    
    var lineNumberString: NSAttributedString? {
        lineNumber.map {
            NSAttributedString(string: "\($0+1)",
                               attributes: attributes(color: .secondaryLabel,
                                                      alignment: .right))
        }
    }
    
    var changeString: NSAttributedString? {
        line.map {
            NSAttributedString(string: $0.prefix,
                               attributes: attributes(color: .label,
                                                      alignment: .center))
        }
    }
    
}

extension NSParagraphStyle {
    
    static func with(alignment: NSTextAlignment, lineHeightMultiple: CGFloat) -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineHeightMultiple = lineHeightMultiple
        return style
    }
    
}
