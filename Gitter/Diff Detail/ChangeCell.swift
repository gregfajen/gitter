//
//  HunkView.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import UIKit

class ChangeCell: UITableViewCell {
    
    let left = ChangeView()
    let right = ChangeView()
    let rule = UIView()
    
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
        
        rule.backgroundColor = UIColor.systemGray3
        rule.frame = CGRect(x: round(rect.size.width - 0.5),
                            y: 0,
                            width: 1,
                            height: rect.size.height)
        rule.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleHeight]
        addSubview(rule)
    }
    
}
