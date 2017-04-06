//
//  SINMessagetoCMChatMessage.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/2/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import Foundation

func SINMessagetoCMChatMessage(_ SINchatMessage: SINMessage) -> CMChatMessage {
    let chatMessage = CMChatMessage()
    
    chatMessage.messageId = SINchatMessage.messageId as String
    chatMessage.senderId = SINchatMessage.senderId as String
    chatMessage.recipientIds = SINchatMessage.recipientIds[0] as? String
    chatMessage.text = SINchatMessage.text as String
    chatMessage.timeStamp = SINchatMessage.timestamp as Date
    
    return chatMessage
}
