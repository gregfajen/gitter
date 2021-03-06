//
//  FilesVC.swift
//  Gitter
//
//  Created by Greg Fajen on 3/6/21.
//

import UIKit

class FilesVC: UITableViewController {
    
    var pull: Pull!
    
    lazy var filesResource = FilesResource(pull)
    var files: [File] { filesResource.value ?? [] }
    
    override func viewWillAppear(_ animated: Bool) {
        filesResource.whenSuccess { _ in
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        title = "Files"
    }
    
    
    
//    lazy var repoResource = RepoResource(fullName: "octocat/Hello-World")
//    
//    var repo: Repo? { repoResource.value }
//    var pulls: [Pull] { repo?.pulls.value ?? [] }
//    
//    override func viewDidLoad() {
//        repoResource.pulls.whenSuccess { _ in
//            self.tableView.reloadData()
//            self.tempStuff()
//        }
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FileCell
        cell.file = files[indexPath.row]
        
        return cell
    }
    
}
