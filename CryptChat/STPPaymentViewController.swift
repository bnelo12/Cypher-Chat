//
//  STPPaymentViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/17/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Stripe
import Parse
import SCLAlertView
import M13ProgressSuite

class STPPaymentViewController: UIViewController, STPPaymentCardTextFieldDelegate {
    @IBOutlet weak var ProgressBar: M13ProgressViewStripedBar!
    @IBOutlet weak var SubmitPaymentButton: UIButton!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var paymentTextField: STPPaymentCardTextField!
    @IBOutlet weak var DonationAmountField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Make a Donation?"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        
        //self.ProgressBar.primaryColor = UIColor.clearColor()
        self.ProgressBar.secondaryColor = UIColor.clear
        self.ProgressBar.backgroundColor = UIColor.clear

        paymentTextField.delegate = self
        
        DonationAmountField.becomeFirstResponder()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 200
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        // Toggle navigation, for example
        if textField.isValid {
            SubmitPaymentButton.backgroundColor = UIColor(red: 27/255.0, green: 162/255.0, blue: 56/255.0, alpha: 1.0);
        } else {
            SubmitPaymentButton.backgroundColor = UIColor.lightGray;
        }
        SubmitPaymentButton.isEnabled = textField.isValid
    }
    
    @IBAction func SubmitPressed(_ sender: UIButton) {
        let card = paymentTextField.cardParams
        self.SubmitPaymentButton.isHidden = true
        self.ProgressBar.isHidden = false
        self.ProgressBar.indeterminate = true
        STPAPIClient.shared().createToken(withCard: card) { (token, error) -> Void in
            if let error = error  {
                print(error)
            }
            else if let token = token {
                self.createBackendChargeWithToken(token) { status in
                    
                }
            }
        }
    }
    
    func createBackendChargeWithToken(_ token: STPToken, completion: (PKPaymentAuthorizationStatus) -> ()) {
        //print(token)
        PFCloud.callFunction(inBackground: "submitAPayment", withParameters:["amount": Int(self.DonationAmountField.text!)!*100, "stripeToken":token.tokenId]) {(object:AnyObject?, error:NSError?) -> Void in
            if error == nil  {
                print(object)
                self.view.endEditing(true)
                let alertView = SCLAlertView()
                alertView.showCloseButton = false
                alertView.addButton("Done") {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "ChatMatesTableView")
                    
                    let navController = MessagesView(rootViewController: vc)
                    self.revealViewController().pushFrontViewController(navController, animated: true)
                }
                alertView.showSuccess("Donation Successful!", subTitle: "Thank you for donating to the project!")
                

            } else {
                //let errorString = error!.userInfo["NSDebugDescription"] as! NSString
                //let token = self.randomAlphaNumericString(6)
                //print(token)
            }
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
