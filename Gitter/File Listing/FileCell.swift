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
        
        accessoryType = .disclosureIndicator
        imageView?.tintColor = imageColor
        imageView?.image = UIImage(named: "file")?.withRenderingMode(.alwaysTemplate)
        textLabel?.text = file?.shape.filename
        detailTextLabel?.text = file?.status.rawValue
    }
    
    var imageColor: UIColor {
        switch file?.status {
            case .added: return .systemGreen
            case .removed: return .systemRed
            default: return .systemGray
        }
        
    }
    
}
