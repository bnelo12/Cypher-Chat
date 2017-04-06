//
//  ChatMatesTableViewController.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/24/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import DZNEmptyDataSet
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


class ChatMateCell: UITableViewCell, DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate {
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var RecentMessageText: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    @IBOutlet weak var NewMessageIcon: UIImageView!
    
}

class ChatMatesTableViewController: UITableViewController {
    @IBOutlet weak var menubutton: UIBarButtonItem!
    @IBOutlet var EmptyDataSetView: UIView!
    
    var myUserId: String?
    var chatMateArray:[String] = [String]()
    var mostRecentMessages:[String] = [String]()
    var timeStampArray:[Date] = [Date]()
    var chatMates:[PFObject] = [PFObject]()
    var player = AVAudioPlayer()
    let url:URL = Bundle.main.url(forResource: "message_sent_alert", withExtension: "mp3")!
    
    var activeDialogViewController: CMDialogViewController?
    

    let dayTimePeriodFormatter = DateFormatter()
    
    var loadingChatMates = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.retrieveChatMatesFromParse()
        NotificationCenter.default.addObserver(self, selector: #selector(SINMessageClientDelegate.messageDelivered(_:)), name: NSNotification.Name(rawValue: configvars.SINCH_MESSAGE_RECIEVED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatMatesTableViewController.messageSent(_:)), name: NSNotification.Name(rawValue: configvars.SINCH_MESSAGE_SENT), object: nil)
         //NSNotificationCenter.defaultCenter().addObserver(self, selector: nil, name: "chatMatesRetrieved", object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myUserId = PFUser.current()?.username
        self.myUserId = PFUser.current()?.username
        
        let logo = UIImage(named: "Message-Messages")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        if self.revealViewController() != nil {
            
            menubutton.target = self.revealViewController()
            menubutton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 200;
        }
        
        self.refreshControl?.addTarget(self, action: #selector(ChatMatesTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        do { player = try AVAudioPlayer(contentsOf: url, fileTypeHint: nil) }
        catch let error as NSError { print(error.description) }
        
        self.tableView.emptyDataSetSource = self as DZNEmptyDataSetSource
        self.tableView.emptyDataSetDelegate = self as DZNEmptyDataSetDelegate

        self.tableView.tableFooterView = UIView()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMateArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMateListPrototypeCell", for: indexPath) as! ChatMateCell
        let username = self.chatMateArray[indexPath.row]
        let mostRecentMessage = self.mostRecentMessages[indexPath.row]
        
        cell.UserNameLabel.text = username
        cell.RecentMessageText.text = mostRecentMessage
        let elapsedTime = timeStampArray[indexPath.row].timeIntervalSinceNow
        print(elapsedTime)
        if elapsedTime <= -604800 {
            dayTimePeriodFormatter.dateFormat = "MM/dd/yy"
        } else if elapsedTime <= -172800 {
            dayTimePeriodFormatter.dateFormat = "EEEE"
        } else if elapsedTime <= -86400 {
            cell.TimeLabel.text = "Yesterday"
            return cell
        } else {
            dayTimePeriodFormatter.dateFormat = "h:mm a"
        }
        
        
        if (self.chatMates[indexPath.row]["read"] as! String == "false") && (self.chatMates[indexPath.row]["reader"] as! String == self.myUserId!) {
            cell.NewMessageIcon.isHidden = false
        } else {
            cell.NewMessageIcon.isHidden = true
        }
        
        let dateString = dayTimePeriodFormatter.string(from: timeStampArray[indexPath.row])
        cell.TimeLabel.text = dateString
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            chatMates[indexPath.row].deleteInBackground()
            self.chatMateArray.remove(at: indexPath.row)
            self.mostRecentMessages.remove(at: indexPath.row)
            self.timeStampArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            //self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserSearchSegue" {
            let dvc = segue.destination as! SearchUsersViewController
            dvc.myUserId = self.myUserId
        }
        if segue.identifier == "OpenDialogSegue" {
            let chatMateIndex = self.tableView.indexPathForSelectedRow
            self.activeDialogViewController = segue.destination as? CMDialogViewController
            self.activeDialogViewController?.chatMateID = self.chatMateArray[(chatMateIndex!.row)]
            self.activeDialogViewController?.myUserId = self.myUserId
        }

    }
    
    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        return EmptyDataSetView
    }
    
    func retrieveChatMatesFromParse() {
        if loadingChatMates == false {
            loadingChatMates = true

            var newChatMateArray:[String] = [String]()
            var newMostRecentMessages:[String] = [String]()
            var newTimeStampArray:[Date] = [Date]()
            var newChatMates:[PFObject] = [PFObject]()
            
            let querySender = PFQuery(className: "Conversation").whereKey("sender", equalTo:self.myUserId!)
            let queryReader = PFQuery(className: "Conversation").whereKey("reader", equalTo:self.myUserId!)
            
            let query = PFQuery.orQuery(withSubqueries: [querySender, queryReader])
            
            query.order(byDescending: "timeStamp")

            query.findObjectsInBackground() { (chatMates: [PFObject]?, error: NSError?) -> Void in
                if error == nil && chatMates != nil {
                    for var i = 0; i < chatMates?.count; i++ {
                        newChatMates.append(chatMates![i])
                        let sender = chatMates![i]["sender"] as! String
                        let reader = chatMates![i]["reader"] as! String
                        if sender == self.myUserId {
                            newChatMateArray.append(reader)
                        } else {
                            newChatMateArray.append(sender)
                        }
                        newMostRecentMessages.append(chatMates![i]["MostRecentMessage"] as! String)
                        newTimeStampArray.append(chatMates![i]["timeStamp"] as! Date)
                    }
                    
                    self.chatMateArray.removeAll()
                    self.mostRecentMessages.removeAll()
                    self.timeStampArray.removeAll()
                    self.chatMates.removeAll()
                    
                    self.chatMateArray = newChatMateArray
                    self.mostRecentMessages = newMostRecentMessages
                    self.timeStampArray = newTimeStampArray
                    self.chatMates = newChatMates
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.loadingChatMates = false
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: configvars.RETRIEVED_CHAT_MATES_FROM_PARSE), object: self)
                    
                } else {
                    print(error)
                    NotificationCenter.default.post(name: Notification.Name(rawValue: configvars.RETRIEVED_CHAT_MATES_FROM_PARSE), object: self)
                    //self.EmptyDataSetView as! EmptyDataSetViewController
                }
            }
        }
    }
    
    func messageSent(_ notification: Notification) {
        //let SINchatMessage = notification.userInfo?["message"] as! SINMessage
        
        //let chatMessage = SINMessagetoCMChatMessage(SINchatMessage)
        
        //saveConversation(chatMessage, myUserId: self.myUserId!, chatMateID: chatMessage.recipientIds!)
        
        //self.retrieveChatMatesFromParse()
        
        //player.play()
    }
    
    
    func messageDelivered(_ notification: Notification) {
        
        self.retrieveChatMatesFromParse()
        
        player.play()
    }


    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.retrieveChatMatesFromParse()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChatMatesTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    //func
}
