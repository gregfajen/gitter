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
        
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var leftMargin: CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return 60
        } else {
            return 10
        }
    }
    
    override func layoutSubviews() {
        label.frame = CGRect(x: leftMargin, y: bounds.size.height - 30, width: 300, height: 30)
        label.font = UIFont(name: "Courier Bold", size: 14)
        label.text = string
        label.textColor = .label
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
