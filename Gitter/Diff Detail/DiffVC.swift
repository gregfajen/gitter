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
    var sectionHeaders = [HunkHeaderView]()
    var sectionFooters = [HunkFooterView]()
    
    override func viewWillAppear(_ animated: Bool) {
        title = file.filename
        diffResource.whenSuccess(didLoad(diff:))
        diffResource.whenFailure(presentErrorAlert)
        
        tableView.backgroundColor = .systemGray6
    }
    
    func didLoad(diff: Diff) {
        sections = diff.hunks.map(DiffSection.init)
        sectionHeaders = sections.map(HunkHeaderView.init)
        sectionFooters = sections.map { _ in HunkFooterView() }
        
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = sectionFooters[section]
        footer.isLast = section == sectionFooters.count - 1
        return footer
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isLast = section == sectionFooters.count - 1
        return isLast ? 0 : 16
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
    
}
