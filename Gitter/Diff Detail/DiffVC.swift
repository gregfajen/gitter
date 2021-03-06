//
//  DiffVC.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import UIKit

class DiffVC: UITableViewController {
    
    var file: File!
    lazy var diffResource = file.diffResource
    
    override func viewWillAppear(_ animated: Bool) {
        title = file.filename
        
        diffResource.whenSuccess { diff in
            self.printDiff(diff)
        }
    }
    
    func printDiff(_ diff: Diff) {
        print(diff.diff)
    }
    
}
