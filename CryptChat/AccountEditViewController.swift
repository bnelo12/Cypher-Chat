//
//  AccountEditViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/30/16.
//  Copyright © 2016 Elo Technology Sciences. All rights reserved.
//

import UIKit
import SCLAlertView
import Parse
import Heimdall

class AccountEditViewController: UITableViewController {
    @IBOutlet weak var EmailLabel: UILabel!

    @IBOutlet weak var DeleteAccountButton: UIButton!
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var PublicKeyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Account Settings"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        
        self.EmailLabel.text = PFUser.current()?.email!
        
        if self.revealViewController() != nil {
            MenuButton.target = self.revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 200
        }
        
        let localHeimdall = Heimdall(tagPrefix: (PFUser.current()?.username)!)
        
        let publicKeyData = localHeimdall?.publicKeyData()
        let publicKeyString = publicKeyData?.base64EncodedString(options: ([]))
            
        // If you want to make this string URL safe,
        // you have to remember to do the reverse on the other side later
        //publicKeyString = publicKeyString!.stringByReplacingOccurrencesOfString("/", withString: "_")
        //publicKeyString = publicKeyString!.stringByReplacingOccurrencesOfString("+", withString: "$")
            
        print(publicKeyString!) // Something along the lines of "MIGfMA0GCSqGSIb3DQEBAQUAA..."
        PublicKeyLabel.text = publicKeyString!
        
        


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DeleteAccount(_ sender: AnyObject) {
        let alert = SCLAlertView
        alert.addButton("Delete Account", target: self, selector: "DeleteAccountAndReturnToIntro")
        alert.addButton("Cancel") { () -> Void in
            
        }
        alert.showCloseButton = false
        alert.showError("Account Deletion", subTitle: "Are you sure you wish to delete your account? This will delete all associated messages to your account from our servers.")
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let title = UILabel()
        title.font = UIFont(name: "Avenir", size: 20)!
        title.textColor = UIColor.black
        
        let header = view as! UITableViewHeaderFooterView
        header.textLabel!.font=title.font
        header.textLabel!.textColor=title.textColor
    }
    
    func DeleteAccountAndReturnToIntro() {
        PFUser.current()?["status"] = AccountStatus.deleted
        PFUser.current()?.saveInBackground() { (suceded: Bool, error: NSError?) -> Void in
            if error == nil {
                PFUser.logOut()
                self.performSegue(withIdentifier: "DeleteAccountSegue", sender: self)
            } else {
                SCLAlertView().showError("Cannot delete account.", subTitle: "Please try again at a later time or report this error to our support staff.", closeButtonTitle: "Okay")
            }
        }
    }
    
    @IBAction func unwindToAccountEdit(_ segue:UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LoadTOS") {
            let dvc = segue.destination as! DocumentViewController
            dvc.documentURLString = "terms-of-service.pdf"
            dvc.documentName = "Terms of Service"
        }
        else if (segue.identifier == "LoadPP") {
            let dvc = segue.destination as! DocumentViewController
            dvc.documentURLString = "privacy-policy.pdf"
            dvc.documentName = "Privacy Policy"
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
