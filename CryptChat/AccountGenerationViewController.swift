//
//  AccountGenerationViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/10/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import M13ProgressSuite
import Heimdall

class AccountGenerationViewController: UIViewController {
    @IBOutlet weak var Logo: UIImageView!
    @IBOutlet weak var ProgressRing: M13ProgressViewSegmentedRing!
    @IBOutlet weak var GenerateKeyButton: UIButton!
    
    override func viewDidLoad() {
        
    
        super.viewDidLoad()
        //ProgressRing.showPercentage = false
        //ProgressRing.indeterminate = true
        //self.performSegueWithIdentifier("UserCreationSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func GenerateKeyPressed(_ sender: AnyObject) {
        //ProgressRing.hidden = false
        GenerateKeyButton.isEnabled = false
        GenerateKeyButton.backgroundColor = UIColor.gray
        //Logo.hidden = true;
        //ProgressRing.indeterminate = true
        let localHeimdall = Heimdall(tagPrefix: (PFUser.current()?.username!)!)
        //let heimdall = localHeimdall, publicKeyData = heimdall!.publicKeyDataX509()
        //print(heimdall?.publicKeyData()?.base64EncodedStringWithOptions([]))
        PFUser.current()!["publicKey"] = (localHeimdall?.publicKeyData())
        PFUser.current()?.saveInBackground() {(success: Bool, error: NSError?) -> Void in
            if error == nil {
                
            } else {
                
            }
        }
        //        PFCloud.callFunctionInBackground("generate-key-pair", withParameters: [:]) {(keyPair:AnyObject?, error:NSError?) -> Void in
//            if error == nil  {
//                print(keyPair)
//            }
//            else {
//                
//            }
//        }
    }
    
}
