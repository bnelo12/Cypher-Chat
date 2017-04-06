//
//  EmptyDataSetMessagesViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/15/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import M13ProgressSuite

class EmptyDataSetMessagesViewController: UIViewController {
    @IBOutlet weak var ProgressRing: M13ProgressViewRing!
    override func viewDidLoad() {
        super.viewDidLoad()
        ProgressRing.showPercentage = false
        ProgressRing.indeterminate = true
        
        NotificationCenter.default.addObserver(self, selector:#selector(EmptyDataSetMessagesViewController.messagesRecieved(_:)) , name: NSNotification.Name(rawValue: configvars.RETRIEVED_MESSAGES_FROM_PARSE), object: nil)
    }
    
    func messagesRecieved(_ notification: Notification) {
        ProgressRing.isHidden = true
        ProgressRing.indeterminate = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
