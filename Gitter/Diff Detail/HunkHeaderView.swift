//
//  HunkHeaderView.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import UIKit

class HunkHeaderView: UIView {
    
    let oldLineRange: ClosedRange<Int>
    let newLineRange: ClosedRange<Int>
    
    let label = UILabel()
    
    init(_ section: DiffSection) {
        self.oldLineRange = section.oldLineRange
        self.newLineRange = section.newLineRange
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        
        self.backgroundColor = UIColor(white: 0.5, alpha: 0.2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.frame = bounds.insetBy(dx: 10, dy: 0)
        label.font = .boldSystemFont(ofSize: 14)
        label.text = string
        addSubview(label)
    }
    
    var string: String {
        "@@ -\(string(for: oldLineRange)) +\(string(for: newLineRange)) @@"
    }
    
    func string(for lineRange: ClosedRange<Int>) -> String {
        if lineRange == 0...0 {
            return "0,0"
        } else {
            return "\(lineRange.lowerBound+1),\(lineRange.count)"
        }
    }
    
}
