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
    var diff: Diff? { diffResource.value }
    var sections = [DiffSection]()
    
    override func viewWillAppear(_ animated: Bool) {
        title = file.filename
        
        diffResource.whenSuccess { diff in
            self.sections = diff.hunks.map(DiffSection.init)
            self.printDiff(diff)
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].pairs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChangeCell
        cell.diff = diff
        cell.pair = sections[indexPath.section].pairs[indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let pair = sections[indexPath.section].pairs[indexPath.item]
        return [(pair.old, false), (pair.new, true)].map { (line, isNew) in
            let view = ChangeView()
            view.diff = diff
            view.line = line
            view.isNew = isNew
            view.frame.size.width = tableView.frame.size.width / 2
            return view.desiredHeight
        }.max() ?? 0
    }
    
    func printDiff(_ diff: Diff) {
        let hunks = diff.diff.hunked()
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
