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
        title = "Files"
        
        filesResource.whenSuccess { _ in
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FileCell
        cell.file = files[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToDiff(for: files[indexPath.item])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func goToDiff(for file: File) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "DiffVC") as! DiffVC
        vc.file = file
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
