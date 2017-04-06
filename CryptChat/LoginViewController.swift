//
//  LoginViewController.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/23/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import M13ProgressSuite
import SCLAlertView


class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var UserNameField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var LoginProgressView: M13ProgressViewStripedBar!
    @IBOutlet weak var BottomButtonAutoLayout: NSLayoutConstraint!

    @IBOutlet weak var LoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LoginButton.layer.borderWidth = 1
        LoginButton.layer.borderColor = UIColor.white.cgColor
        
        //self.LoginProgressView.primaryColor = UIColor.clearColor()
        self.LoginProgressView.secondaryColor = UIColor.clear
        //self.LoginProgressView.backgroundColor = UIColor.clearColor()
        
        self.UserNameField.becomeFirstResponder()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide:"), name: UIKeyboardDidHideNotification, object: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "LoginSegue") {
            let dvc = segue.destination as! Reveal
            dvc.myUserId = UserNameField.text
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
    }

    
    //MARK: - Actions
    @IBAction func LoginPressed(_ sender: AnyObject) {
        
        if UserNameField.text!.isEmpty {
            return
        }
        
        self.LoginProgressView.perform(M13ProgressViewActionNone, animated: true)
        
        self.LoginButton.isEnabled = false
        self.LoginButton.isHidden = true
        self.LoginProgressView.indeterminate = true
        self.LoginProgressView.isHidden = false
        
        PFUser.logInWithUsername(inBackground: UserNameField.text!, password:PasswordField.text!) { (user, error) -> Void in
            if user != nil {
                if user!["status"] == nil || user!["status"] as! String != AccountStatus.deleted {
                // Yes, User Exists
                    self.LoginProgressView.indeterminate = false
                    self.LoginProgressView.primaryColor = UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0);
                    self.LoginProgressView.setProgress(1, animated: true)
                    self.LoginProgressView.perform(M13ProgressViewActionSuccess, animated: true)
 
                    let appDelgate = UIApplication.shared.delegate as! AppDelegate
                    appDelgate.initSinchClient(self.UserNameField.text!)
                    let delay = 1 * Double(NSEC_PER_SEC)
                    let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: time) {
                        self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                    }
                } else {
                    PFUser.logOut()
                    SCLAlertView.showError("Login Error", subTitle: "This account has been deleted.")
                    self.loginFailed()
                }
            } else {
                //self.ErrorLabel.hidden = false;
                //self.ErrorLabel.text = "Invalid User Name or Password"
                SCLAlertView.showError("Login Error", subTitle: error!.localizedDescription)
                self.loginFailed()
                //self.LoginProgressView.primaryColor = UIColor.redColor()
                //self.LoginProgressView.secondaryColor = UIColor.redColor()
                //self.LoginProgressView.setProgress(1, animated: true)
                //self.LoginProgressView.performAction(M13ProgressViewActionFailure, animated: true)
            }
        }
    }
    
    func loginFailed() {
        self.view.endEditing(true)
        self.LoginButton.isEnabled = true
        self.LoginButton.isHidden = false
        self.LoginProgressView.isHidden = true
        self.LoginProgressView.indeterminate = false
    }
    
    @IBAction func unwindToLogin(_ segue:UIStoryboardSegue) {
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
