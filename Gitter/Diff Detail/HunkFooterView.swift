//
//  HunkFooterView.swift
//  Gitter
//
//  Created by Greg Fajen on 3/7/21.
//

import UIKit

class HunkFooterView: UIView {
    
    let rule = UIView()
    
    var isLast = false
    
    override func layoutSubviews() {
        rule.frame = CGRect(x: 20, y: 12, width: bounds.size.width - 40, height: 1)
        rule.backgroundColor = UIColor.systemGray4
        rule.alpha = isLast ? 0 : 1
        addSubview(rule)
    }
    
}
