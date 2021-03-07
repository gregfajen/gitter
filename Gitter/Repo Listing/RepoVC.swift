//
//  RepoVC.swift
//  Gitter
//
//  Created by Greg Fajen on 3/4/21.
//

import UIKit

fileprivate let repoName = "magicalpanda/MagicalRecord"

class RepoVC: UITableViewController {
    
    lazy var repoResource = RepoResource(fullName: repoName)
    
    var repo: Repo? { repoResource.value }
    var pulls: [Pull] { repo?.pulls.value ?? [] }
    
    override func viewDidLoad() {
        repoResource.whenSuccess { repo in
            self.title = repo.name
        }
        
        repoResource.pulls.whenSuccess { _ in
            self.tableView.reloadData()
        }
        
        repoResource.pulls.whenFailure(presentErrorAlert)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pulls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PullCell
        cell.pull = pulls[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToFiles(for: pulls[indexPath.item])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func goToFiles(for pull: Pull) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "FilesVC") as! FilesVC
        vc.pull = pull
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension UIViewController {
    
    func presentErrorAlert(error: Error) {
        let title = "Error"
        let message = (error as? LocalizedError)?.errorDescription ?? "An unknown error occurred."
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true)
    }
    
}
