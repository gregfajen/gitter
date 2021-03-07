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

        accessoryType = .disclosureIndicator
        imageView?.tintColor = .systemBlue
        imageView?.image = UIImage(named: "pull")?.withRenderingMode(.alwaysTemplate)
        textLabel?.text = pull?.shape.title
        detailTextLabel?.text = pull?.shape.body
    }
    
}
