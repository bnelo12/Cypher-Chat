//
//  ForgotPasswordViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/16/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import M13ProgressSuite

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var ProgressView: M13ProgressViewStripedBar!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var EmailTextField: UITextField!
    
    var userRecoveryEmail: String?
    var userUsername: String?
    
    
    override func viewDidLoad() {
        EmailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TokenScreenSegue" {
            let dvc = segue.destination as! TokenViewController
            dvc.userRecoveryEmail = self.userRecoveryEmail!
            dvc.userUsername = self.userUsername!
        }
    }
    
    @IBAction func SendButtonPressed(_ sender: AnyObject) {
        if EmailTextField.text!.isEmpty {
            self.ErrorLabel.text = "Please Enter an Email"
        } else {
            self.ProgressView.indeterminate = true
            self.ProgressView.isHidden = false
            self.userRecoveryEmail = EmailTextField.text!
            let query = PFUser.query()!
            query.whereKey("email", equalTo: self.userRecoveryEmail!)
            query.findObjectsInBackground {(user: [PFObject]?, error: NSError?) -> Void in
                if (error == nil && user?.isEmpty == false) {
                    let token = self.randomAlphaNumericString(6)
                    let recoverAccountData = PFObject(className: "AccountRecoveryData")
                    
                    self.userUsername = user![0]["username"] as? String
                    
                    recoverAccountData["email"] = self.userRecoveryEmail
                    recoverAccountData["token"] = token
                    recoverAccountData["time_stamp"] = Date()
                    
                    recoverAccountData.saveInBackground()
                    
                    //self.performSegueWithIdentifier("TokenScreenSegue", sender: nil)
                    
                    PFCloud.callFunction(inBackground: "sendEmailToUser", withParameters:["token": token, "email": self.userRecoveryEmail!]) {(object:AnyObject?, error:NSError?) -> Void in
                        if error == nil  {
                                //self.ErrorLabel.text = object as? String
                                //print(token)
                        } else {
                            //let errorString = error!.userInfo["NSDebugDescription"] as! NSString
                            //let token = self.randomAlphaNumericString(6)
                            //print(token)
                        }
                    }
                } else {
                    self.ErrorLabel.text = "Account does not exist"
                    self.ErrorLabel.isHidden = false
                    self.ProgressView.indeterminate = false
                    self.ProgressView.isHidden = true
                }
            }
        }
    }
    func randomAlphaNumericString(_ length: Int) -> String {
        
        let allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ023456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<length) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.characters.index(allowedChars.startIndex, offsetBy: randomNum)]
            randomString += String(newCharacter)
        }
        
        return randomString
    }
}
