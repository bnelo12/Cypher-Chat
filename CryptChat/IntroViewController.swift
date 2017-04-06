//
//  IntroViewController.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/23/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import SAConfettiView

class IntroViewController: UIViewController {
    @IBOutlet weak var confettiView: SAConfettiView!
    @IBOutlet weak var SignUpButton: UIButton!
    @IBOutlet weak var SignInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SignUpButton.layer.borderWidth = 1
        SignUpButton.layer.borderColor = UIColor.white.cgColor
        SignInButton.layer.borderWidth = 1
        SignInButton.layer.borderColor = UIColor.white.cgColor
        
        //self.view.addSubview(confettiView)
        confettiView.type = .triangle
        confettiView.colors = [UIColor.white]
        confettiView.intensity = 0.5
        confettiView.startConfetti()

        
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background2.jpg")!)
        let settings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        //PFUser.logOut()
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            let appDelgate = UIApplication.shared.delegate as! AppDelegate
            print(PFUser.current()!["username"] as! String)
            appDelgate.initSinchClient(PFUser.current()!["username"] as! String)
            self.performSegue(withIdentifier: "RestoreSessionSegue", sender: nil)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToIntro(_ segue:UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "RestoreSessionSegue") {
            let dvc = segue.destination as! Reveal
            dvc.myUserId = PFUser.current()!["username"] as? String
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
