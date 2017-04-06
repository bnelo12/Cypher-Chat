//
//  CMDialogTableTableViewController.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/25/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import M13ProgressSuite
import DZNEmptyDataSet
import DGTemplateLayoutCell
import QuartzCore
import Heimdall

class CMChatMessage {
    var messageId: String?
    var recipientIds: String?
    var senderId: String?
    var text: String?
    var headers: NSDictionary?
    var timeStamp: Date?
}

class CMMessageCell: UITableViewCell, DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate {
    //@IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var LeftMessageBlock: InsetLabel!
    
    @IBOutlet weak var RightMessageBlock: InsetLabel!
}

class InsetLabel: UILabel {
    var textInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = textInsets.apply(bounds)
        rect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        return textInsets.inverse.apply(rect)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: textInsets.apply(rect))
    }
    
}

extension UIEdgeInsets {
    var inverse: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
    func apply(_ rect: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(rect, self)
    }
}

class CMDialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var player = AVAudioPlayer()
    let url:URL = Bundle.main.url(forResource: "message_sent_alert", withExtension: "mp3")!
    
    var chatMateID: String?
    var myUserId: String?
    var messageArray = [CMChatMessage]()
    var heightAtIndexPath = [AnyHashable: Any]()
    
    var partnersPublicKey = Data()
    
    var KeyboardIsShowing = false

    @IBOutlet weak var MessageEditField: UITextView!
    @IBOutlet var EmptyDataSetView: UIView!
    @IBOutlet var MessageHistoryTableView: UITableView!
    @IBOutlet weak var BottomContentOffset: NSLayoutConstraint!
    @IBOutlet weak var MessageSentProgressView: M13ProgressViewStripedBar!
    @IBOutlet weak var MessageSendBottomConetentOffset: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(CMDialogViewController.messageRecieved(_:)), name: NSNotification.Name(rawValue: configvars.SINCH_MESSAGE_RECIEVED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CMDialogViewController.messageSent(_:)), name: NSNotification.Name(rawValue: configvars.SINCH_MESSAGE_SENT), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(CMDialogViewController.messagesWereDownloaded(_:)) , name: NSNotification.Name(rawValue: configvars.RETRIEVED_MESSAGES_FROM_PARSE), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.MessageHistoryTableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let query = PFUser.query()?.whereKey("username", equalTo: self.chatMateID!)
        query?.findObjectsInBackground() {(user: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                 self.partnersPublicKey = user![0]["publicKey"] as! Data
                self.retrieveMessagesFromParseWithChatMateID(self.chatMateID!)
                //print(publicKey.base64EncodedStringWithOptions([]))
            } else {
                print(error)
            }
        }
        self.navigationItem.title = chatMateID!
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!]
        self.MessageSentProgressView.indeterminate = false;
        self.MessageSentProgressView.isHidden = true
        
        do { player = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil) }
        catch let error as NSError { print(error.description) }
        
        self.MessageHistoryTableView.rowHeight = UITableViewAutomaticDimension;
        self.MessageHistoryTableView.estimatedRowHeight = 50.0
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CMDialogViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CMDialogViewController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CMDialogViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.MessageHistoryTableView.emptyDataSetSource = self
        self.MessageHistoryTableView.emptyDataSetDelegate = self
        
        MessageEditField.becomeFirstResponder()
        
        //MesseageSentProgressView.setProgress(0, animated: false)
        
        //self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        //print(chatMateID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //print(self.messageArray.count)
        return self.messageArray.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messageArray[indexPath.row].senderId == self.chatMateID {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CMMessageLeftPrototypeCell", for: indexPath) as! CMMessageCell
            let message = self.messageArray[indexPath.row].text!
            cell.LeftMessageBlock.text = message
            cell.LeftMessageBlock.textInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            //cell.LeftMessageBlock.layer.shadowOpacity = 0.2
            //cell.LeftMessageBlock.shadowOffset = CGSize(width: 1.0, height: 1.0)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CMMessageRightPrototypeCell", for: indexPath) as! CMMessageCell
            let message = self.messageArray[indexPath.row].text!
            cell.RightMessageBlock.layer.cornerRadius = 10
            cell.RightMessageBlock.text = message
            cell.RightMessageBlock.textInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            return cell
        }
    }
    

    
    func scrollTableViewToBottom(_ animated: Bool) {
        let rowNumber = self.MessageHistoryTableView.numberOfRows(inSection: 0)
        if rowNumber > 0 {
            self.MessageHistoryTableView.scrollToRow(at: IndexPath(row: rowNumber-1, section: 0), at: UITableViewScrollPosition.bottom, animated:animated)
        }
        
    }

   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.dg_heightForCellWithIdentifier("CMMessageRightPrototypeCell", indexPath: indexPath, configuration: { (cell) -> Void in
            let cell = cell as! CMMessageCell
            let message = self.messageArray[indexPath.row].text!
            cell.RightMessageBlock.text = message
            cell.RightMessageBlock.textInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        })
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.dg_heightForCellWithIdentifier("CMMessageRightPrototypeCell", indexPath: indexPath, configuration: { (cell) -> Void in
            if self.messageArray.count > 0 {
                let cell = cell as! CMMessageCell
                let message = self.messageArray[indexPath.row].text!
                cell.RightMessageBlock.text = message
                cell.RightMessageBlock.textInsets = UIEdgeInsetsMake(10, 10, 10, 10)
            }
        })
    }

    

    func retrieveMessagesFromParseWithChatMateID(_ chatMateId: String) {
        let userNames: [String] = [self.myUserId!, self.chatMateID!]
        let localHeimdall = Heimdall(tagPrefix: (PFUser.current()?.username!)!)
        print (localHeimdall?.publicKeyData())
        let query = PFQuery(className: "SinchMessage")
        query.whereKey("owner", containedIn: [userNames[0]])
        query.whereKey("senderId", containedIn: userNames)
        query.whereKey("recipientId", containedIn: userNames)
        query.order(byDescending: "timeStamp")
        query.limit = 50
        query.findObjectsInBackground() {(chatMessageArray: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: configvars.RETRIEVED_MESSAGES_FROM_PARSE), object: self)
                for i in 0 ..< chatMessageArray!.count {
                    let chatMessage = CMChatMessage()
                    
                    chatMessage.messageId = (chatMessageArray?[i])?["messageId"] as? String
                    chatMessage.senderId = (chatMessageArray?[i])?["senderId"] as? String
                    chatMessage.recipientIds = (chatMessageArray?[i])?["recipientId"] as? String
                    print(localHeimdall!.decrypt(((chatMessageArray?[i])?["text"] as! String)))
                    //print(((chatMessageArray?[i])?["text"] as! String) + "\n\n\n")
                    chatMessage.text = localHeimdall!.decrypt(((chatMessageArray?[i])?["text"] as? String)!)
                    chatMessage.timeStamp = (chatMessageArray?[i])?["timeStamp"] as? Date
                    
                    self.messageArray.append(chatMessage)
                    
                }
                //print(self.messageArray.count)
                self.messageArray = self.messageArray.reversed()
                self.MessageHistoryTableView.reloadData()
                self.scrollTableViewToBottom(false)
                //localHeimdall?.destroy()
            }
        }

    }

    @IBAction func SendButtonPressed(_ sender: AnyObject) {
        if MessageEditField.text!.isEmpty {
            return
        } else {
            MessageSentProgressView.perform(M13ProgressViewActionNone, animated: false)
            MessageSentProgressView.isHidden=false;
            self.MessageSentProgressView.indeterminate = true;
            let chatMessage = CMChatMessage()
            chatMessage.text = MessageEditField.text!
            self.messageArray.append(chatMessage)
            self.MessageHistoryTableView.beginUpdates()
            self.MessageHistoryTableView.insertRows(at: [
                IndexPath(row: messageArray.count-1, section: 0)
                ], with: .none)
            self.MessageHistoryTableView.endUpdates()
            self.scrollTableViewToBottom(true)
            //print(self.partnersPublicKey)
            self.navigationItem.title = "Encrypting..."
            if let localHeimdall = Heimdall(tagPrefix: (PFUser.current()?.username!)!) {
                //let heimdall = localHeimdall, publicKeyData = heimdall.publicKeyDataX509()
                print(localHeimdall.publicKeyData())
                let clearText = MessageEditField.text!
                let encryptedMessage = localHeimdall.encrypt(clearText)
                saveMessageOnParse(encryptedMessage!, recipientId: self.chatMateID!, senderId: self.myUserId!, timeStamp: Date())
                //localHeimdall.destroy()
            }
            if let partnerHeimdall = Heimdall(publicTag: "com." + self.myUserId! + "." + self.chatMateID!, publicKeyData: self.partnersPublicKey) {
                //print(self.partnersPublicKey)
                let clearText = MessageEditField.text!
                let encryptedMessage = partnerHeimdall.encrypt(clearText)
                let delegate = UIApplication.shared.delegate as! AppDelegate
                delegate.sendTextMessage(encryptedMessage!, recipientID: chatMateID!)
                self.navigationItem.title = "Sending..."
                self.MessageEditField.text = ""
                //partnerHeimdall.destroy()
            }
        }
    }
    
    func messageRecieved(_ notification: Notification) {
        let SINchatMessage = notification.userInfo?["message"] as! SINMessage
        
        let chatMessage = SINMessagetoCMChatMessage(SINchatMessage)
        
            if chatMessage.senderId! == self.chatMateID {
            if let localHeimdall = Heimdall(tagPrefix: (PFUser.current()?.username!)!) {
             
                chatMessage.text = localHeimdall.decrypt(chatMessage.text!)!
            }
            self.messageArray.append(chatMessage)
            self.MessageHistoryTableView.beginUpdates()
            self.MessageHistoryTableView.insertRows(at: [
            IndexPath(row: messageArray.count-1, section: 0)
            ], with: .none)
            self.MessageHistoryTableView.endUpdates()
            self.scrollTableViewToBottom(true)
        
        }
        
        player.play()

    }
    
    func messageSent(_ notification: Notification) {
        let SINchatMessage = notification.userInfo?["message"] as! SINMessage
        
        let chatMessage = SINMessagetoCMChatMessage(SINchatMessage)
        
        saveConversation(chatMessage, myUserId: self.myUserId!, chatMateID: self.chatMateID!)
        
        MessageSentProgressView.perform(M13ProgressViewActionSuccess, animated: true)
        
        self.navigationItem.title = self.chatMateID
        
        let delay = 0.25 * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.MessageSentProgressView.perform(M13ProgressViewActionNone, animated: false)
            self.MessageSentProgressView.isHidden = true
        }
        
        //player.play()
    }
    
    func messagesWereDownloaded(_ notification: Notification) {

    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        MessageSendBottomConetentOffset.constant = (keyboardSize?.height)!
        BottomContentOffset.constant = (keyboardSize?.height)!
        
        self.view.layoutIfNeeded()
        
        scrollTableViewToBottom(false)
    }

    func keyboardWillHide(_ notification: Notification) {
        MessageSendBottomConetentOffset.constant = 0
        BottomContentOffset.constant = 0
        
        self.view.layoutIfNeeded()
        
        scrollTableViewToBottom(false)
    }

}

extension CMDialogViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        return EmptyDataSetView
    }
}
