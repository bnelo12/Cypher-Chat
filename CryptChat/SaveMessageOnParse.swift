//
//  SaveMessageOnParse.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 4/19/16.
//  Copyright © 2016 Elo Technology Sciences. All rights reserved.
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


func saveMessageOnParse(_ message: SINMessage) {
    let query = PFQuery(className: "SinchMessage")
    query.whereKey("messageId", equalTo: message.messageId)
    query.findObjectsInBackground() {(messageArray: [PFObject]?, error: NSError?) -> Void in
        if (error == nil) {
            // If the SinchMessage is not already saved on Parse (an empty array is returned), save it.
            let messageObject = [PFObject(className: "SinchMessage")]
            do {
                if messageArray?.count <= 0 {
                    //This is where I changed the code!!!!!!!
                    messageObject[0]["messageId"] = message.messageId
                    messageObject[0]["owner"] = message.recipientIds[0]
                    messageObject[0]["senderId"] = message.senderId
                    messageObject[0]["recipientId"] = message.recipientIds[0]
                    messageObject[0]["text"] = message.text
                    messageObject[0]["timeStamp"] = message.timestamp
                }
                try PFObject.saveAll(messageObject)
            }
            catch {
                
            }
        } else {
            print("Error: " + (error?.description)!)
        }
    }
}

func saveMessageOnParse(_ text: String, recipientId: String, senderId: String, timeStamp: Date) {
    let messageObject = [PFObject(className: "SinchMessage")]
    do {
        messageObject[0]["owner"] = senderId
        messageObject[0]["senderId"] = senderId
        messageObject[0]["recipientId"] = recipientId
        messageObject[0]["text"] = text
        messageObject[0]["timeStamp"] = timeStamp
        try PFObject.saveAll(messageObject)
    }
    catch {
                
    }
}

