//
//  RepoVC.swift
//  Gitter
//
//  Created by Greg Fajen on 3/4/21.
//

import UIKit

class RepoVC: UITableViewController {
    
    lazy var repoResource = RepoResource(fullName: "octocat/Hello-World")
    
    var repo: Repo? { repoResource.value }
    var pulls: [Pull] { repo?.pulls.value ?? [] }
    
    override func viewDidLoad() {
        repoResource.pulls.whenSuccess { _ in
            self.tableView.reloadData()
            self.tempStuff()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pulls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PullCell
        cell.pull = pulls[indexPath.row]
        
        return cell
    }
    
    func tempStuff() {
        let pull = pulls[1]
        pull.filesResource.whenComplete { result in
            self.tempStuff2(result.success!)
        }
    }
    
    func tempStuff2(_ files: [File]) {
        let file = files.first!
        
        file.diffResource.whenComplete { result in
            print(result)
            print("")
        }
        
        print(file)
        print("")
    }
    
}
