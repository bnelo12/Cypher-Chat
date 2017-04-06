//
//  SignUpViewController.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/23/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import SCLAlertView
import M13ProgressSuite

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var SignUpButton: UIButton!

    @IBOutlet weak var ConfirmPasswordField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var UserNameField: UITextField!
    @IBOutlet weak var ScrollView: UIScrollView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        SignUpButton.layer.borderWidth = 1
        SignUpButton.layer.borderColor = UIColor.white.cgColor
        
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
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.ScrollView.contentInset.bottom = keyboardSize.height;
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.ScrollView.contentInset.bottom = 0;
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) 
        }
    }
    // MARK: - Actions
    @IBAction func SignUpPressed(_ sender: AnyObject) {
        self.view.endEditing(true)
        let usrEntered = UserNameField.text
        let pwdEntered = PasswordField.text
        let confpwdEntered = ConfirmPasswordField.text
        let emlEntered = EmailField.text
        
        if usrEntered != "" && pwdEntered != "" && emlEntered != "" {
            if pwdEntered == confpwdEntered {
                let progressHUD = M13ProgressHUD(progressView: M13ProgressViewRing())
                progressHUD?.progressViewSize = CGSize(width: 100.0, height: 100.0)
                self.view.addSubview(progressHUD!)
                progressHUD?.show(false)
                progressHUD?.indeterminate = true
                
                let newuser = PFUser()
                newuser.username = usrEntered
                newuser.password = pwdEntered
                newuser.email = emlEntered
                newuser["userID"] = usrEntered?.uppercased()
                newuser["status"] = AccountStatus.active
                
                newuser.signUpInBackground {
                (succeeded: Bool, error: NSError?) -> Void in
                if error == nil {
                    self.signInSuccesful()
                    let appDelgate = UIApplication.shared.delegate as! AppDelegate
                    appDelgate.initSinchClient(self.UserNameField.text!)
                    PFCloud.callFunction(inBackground: "sendWelcomeEmailToUser", withParameters:["email": self.EmailField.text!]) {(object:AnyObject?, error:NSError?) -> Void in
                        if error == nil  {
                            //self.ErrorLabel.text = object as? String
                            //print(token)
                        } else {
                            //let errorString = error!.userInfo["NSDebugDescription"] as! NSString
                            //let token = self.randomAlphaNumericString(6)
                            //print(token)
                        }
                    }
                    self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                } else {
                    progressHUD.hide(false)
                    let errorString = error!.userInfo["error"] as! NSString
                    SCLAlertView().showError("Sign Up Failed", subTitle:errorString as String)
                    self.view.endEditing(true)
                    // Show the errorString somewhere and let the user try again.
                }
            }

            
            } else {
                SCLAlertView.showError("Sign Up Failed", subTitle: "Passwords Do Not Match.")
                self.view.endEditing(true)
            }
        } else {
            SCLAlertView.showError("Sign Up Failed", subTitle: "All fields are required.")
            self.view.endEditing(true)
        }
        
    }
    
    func signInSuccesful() {
        self.performSegue(withIdentifier: "SignUpSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "SignUpSegue") {

        }
        else if (segue.identifier == "LoadTOS") {
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
    
    @IBAction func unwindToSignUp(_ segue:UIStoryboardSegue) {
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
