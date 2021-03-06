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
        let hunks = diff.diff.hunked(sourceLineCount: diff.before.count, targetLineCount: diff.after.count)
        
        
        let old = diff.before
        let new = diff.after
        
        for hunk in hunks {
            print("")
            print("")
            print("")
            
            for change in hunk.changes {
                switch change {
                    case .insert(let targetLine):
                        let line = new[targetLine]
                        print(" + \(line)")
                    case .remove(let sourceLine):
                        let line = old[sourceLine]
                        print(" - \(line)")
                    case .equal(let sourceLines, _):
                        for sourceLine in sourceLines {
                            let line = old[sourceLine]
                            print("   \(line)")
                        }
                }
            }
        }
    }
    
}
