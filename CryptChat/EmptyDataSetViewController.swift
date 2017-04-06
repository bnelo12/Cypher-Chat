//
//  EmptyDataSetViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/14/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import M13ProgressSuite

class EmptyDataSetViewController: UIViewController {
    @IBOutlet weak var LogoNameLabel: UILabel!
    @IBOutlet weak var MoreInfoLabel: UILabel!
    @IBOutlet weak var ProgressView: M13ProgressViewRing!

    var hasFinishedLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressView.showPercentage = false
        ProgressView.indeterminate = true
        
        let moreInfo = "You have no messages.\n Press NEW to send a message!"
        
        let moreInfoAttributedString = NSAttributedString(string: moreInfo,
            attributes: [NSFontAttributeName:UIFont(
                name:"Avenir",
                size: 17)!])
        //MoreInfoLabel.attributedText = moreInfoAttributedString
        
        NotificationCenter.default.addObserver(self, selector:#selector(EmptyDataSetViewController.chatMatesRecieved) , name: NSNotification.Name(rawValue: configvars.RETRIEVED_CHAT_MATES_FROM_PARSE), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    func chatMatesRecieved() {
        ProgressView.isHidden = true
        ProgressView.indeterminate = false
        //LogoNameLabel.hidden = false
        //MoreInfoLabel.hidden = false
    }
    
}
