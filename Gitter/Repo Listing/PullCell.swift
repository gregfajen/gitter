//
//  PullCell.swift
//  Gitter
//
//  Created by Greg Fajen on 3/5/21.
//

import UIKit

class PullCell: UITableViewCell {
    
    var pull: Pull? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.textLabel?.text = pull?.shape.title
        self.detailTextLabel?.text = pull?.shape.body
    }
    
}
