//
//  SaveMostRecentMessage.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/27/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import Foundation
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}



func saveConversation(_ message: CMChatMessage, myUserId: String, chatMateID: String) {
    //Update User most recent message
    let CMS = [myUserId, chatMateID]

    var  query = PFQuery(className: "Conversation").whereKey("sender", containedIn: CMS)
    query = query.whereKey("reader", containedIn: CMS)
    
    
    query.findObjectsInBackground() {(messageArray: [PFObject]?, error: NSError?) -> Void in
        if (error == nil) {
            // If the SinchMessage is not already saved on Parse (an empty array is returned), save it.
            let messageObject = PFObject(className: "Conversation")
            if messageArray?.count <= 0 {
                messageObject["sender"] = myUserId
                messageObject["reader"] = chatMateID
                messageObject["MostRecentMessage"] = message.text
                messageObject["read"] = "false"
   
                
                messageObject["timeStamp"] = message.timeStamp
                messageObject.saveInBackground()
            } else {
                messageArray![0]["sender"] = myUserId
                messageArray![0]["reader"] = chatMateID
                messageArray![0]["MostRecentMessage"] = message.text
                messageArray![0]["timeStamp"] = message.timeStamp
                messageArray![0].saveInBackground()
            }
            
        } else {
            print("Error: " + (error?.description)!)
        }

    }

}
