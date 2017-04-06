//
//  Reveal.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/25/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit

class Reveal: SWRevealViewController {
    var myUserId: String?

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sw_front" {
            let dvc = segue.destination as! MessagesView
            dvc.myUserId = self.myUserId
        }
        if segue.identifier == "sw_rear" {
            let dvc = segue.destination as! MenuViewController
            dvc.myUserId = self.myUserId
        }
    }
    
    override func revealToggle(_ sender: AnyObject!) {
        super.revealToggle(sender)
        view.endEditing(true)
    }

}
