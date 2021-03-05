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
        repoResource.pulls.whenSuccess { pulls in
            print(pulls.map(\.shape).map(\.state))
            self.tableView.reloadData()
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
    
}
