//
//  FileCell.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import Foundation

import UIKit

class FileCell: UITableViewCell {
    
    var file: File? {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.text = file?.shape.filename
    }
    
}
