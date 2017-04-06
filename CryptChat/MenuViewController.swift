//
//  MenuViewController.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/25/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse

class MenuViewController: UIViewController {
    @IBOutlet weak var LogoutButton: UIButton!
    @IBOutlet weak var MyAccountButton: UIButton!
    @IBOutlet weak var UsernameLabel: UILabel!

    var myUserId: String?
    
    @IBAction func LogoutPressed(_ sender: AnyObject) {
        PFUser.logOutInBackground()
        //print(PFUser.currentUser())
        self.navigationController?.dismiss(animated: true, completion: nil)
        //SINClient.unregisterPushNotificationDeviceToken(self.
        //SINClient.unregisterPushNotificationDeviceToken()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MyAccountButton.layer.borderWidth = 1
        //MyAccountButton.layer.borderColor = UIColor.whiteColor().CGColor
        //LogoutButton.layer.borderWidth = 1
        //LogoutButton.layer.borderColor = UIColor.whiteColor().CGColor
        myUserId = PFUser.current()?.username
        UsernameLabel.text = myUserId!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MenuToMessages" {
            //myUserId = PFUser.currentUser()?.username
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
