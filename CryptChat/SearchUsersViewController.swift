//
//  SearchUsersViewController.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/27/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var UserLabel: UILabel!
    
}

class SearchUsersViewController: UIViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var UsersTableView: UITableView!
    
    var searchedUsers = [String]()
    var myUserId: String?
    
    var activeDialogViewController: CMDialogViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myUserId = PFUser.current()?.username
        SearchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersPrototypeCell", for: indexPath) as! UserTableViewCell
        cell.UserLabel.text = searchedUsers[indexPath.row]
        return cell
    }
    
    func findUser() {
        searchedUsers.removeAll()
        let query = PFUser.query()!.whereKey("userID", hasPrefix: self.SearchBar.text!.uppercased())
        query.whereKey("username", notEqualTo: myUserId!)
        query.findObjectsInBackground { (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for var i = 0; i < results?.count; i++ {
                    self.searchedUsers.append(results![i]["username"] as! String)
                }
                self.UsersTableView.reloadData()
            } else {
                self.searchedUsers.removeAll()
                self.UsersTableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchedUsers.removeAll()
        self.UsersTableView.reloadData()
        self.findUser()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        findUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatMateIndex = self.UsersTableView.indexPathForSelectedRow
        self.activeDialogViewController = segue.destination as? CMDialogViewController
        self.activeDialogViewController?.chatMateID = self.searchedUsers[(chatMateIndex!.row)]
        self.activeDialogViewController?.myUserId = self.myUserId
    }
}
