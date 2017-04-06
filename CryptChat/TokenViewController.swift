//
//  TokenViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/16/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse

class TokenViewController: UIViewController {

    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var ConfirmPasswordField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var TokenTextField: UITextField!
    
    var userRecoveryEmail: String?
    var userUsername: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TokenTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SubmitPressed(_ sender: AnyObject) {
        if PasswordField.text! != ConfirmPasswordField.text! {
            ErrorLabel.text = "Passwords do not match"
            ErrorLabel.isHidden = false
        } else {
            let query = PFQuery(className: "AccountRecoveryData")
            query.whereKey("email", equalTo: self.userRecoveryEmail!)
            query.addDescendingOrder("time_stamp")
            query.findObjectsInBackground {(recoveryData: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if (recoveryData![0]["token"]! as! String) == self.TokenTextField.text! {
                        self.ErrorLabel.text = "Tokens Match!"
                        self.ErrorLabel.isHidden = false
                        
                        //Update the users password
                        //Must add cloud code to update users password
                        PFCloud.callFunction(inBackground: "assignPasswordToUser", withParameters:["email": self.userRecoveryEmail!, "password": self.PasswordField.text!]) {(object:AnyObject?, error:NSError?) -> Void in
                            if error == nil  {
                                PFUser.logInWithUsername(inBackground: self.userUsername!, password:self.PasswordField.text!) { (user, error) -> Void in
                                    if user != nil {
                                        let appDelgate = UIApplication.shared.delegate as! AppDelegate
                                        appDelgate.initSinchClient(self.userUsername!)
                                        self.performSegue(withIdentifier: "LoginFromForgotPassword", sender: nil)
                                    }
                                }
                            } else {
                                //let errorString = error!.userInfo["NSDebugDescription"] as! NSString
                                //let token = self.randomAlphaNumericString(6)
                                print(error)
                            }

                        }
                        
                    } else {
                        self.ErrorLabel.text = "Tokens Do Not Match!"
                        self.ErrorLabel.isHidden = false
                    }
                } else {
                    
                }
            }
        }
    }

    @IBAction func ResendEmailPressed(_ sender: AnyObject) {
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
