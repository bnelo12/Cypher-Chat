//
//  AppDelegate.swift
//  CryptChat
//
//  Created by Benjamin Elo on 2/23/16.
//  Copyright © 2016 Elo Software. All rights reserved.
//

import UIKit
import Parse
import Stripe

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, SINClientDelegate, SINMessageClientDelegate, SINManagedPushDelegate {

    var window: UIWindow?
    var sinchClient = SINClient?()
    var sinchMessageClient = SINMessageClient?()
    var push = SINManagedPush?()

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        self.push = Sinch.managedPush(with: SINAPSEnvironment.development)
        self.push?.delegate = self
        self.push?.setDesiredPushTypeAutomatically()
        
        Parse.setLogLevel(PFLogLevel.info)
        
        Stripe.setDefaultPublishableKey("pk_test_nBbwn9FcvPuv8KSzxJ4Wi2Pw")
        
        let config = ParseClientConfiguration(block: {
            (ParseMutableClientConfiguration) -> Void in
            
            ParseMutableClientConfiguration.applicationId = configvars.PARSE_APPLICATION_ID;
            ParseMutableClientConfiguration.clientKey = configvars.PARSE_CLIENT_KEY;
            ParseMutableClientConfiguration.server = "https://salty-ocean-64917.herokuapp.com/parse";
        });
        
        Parse.initialize(with: config);
        
        if PFUser.current() != nil {
            let appDelgate = UIApplication.shared.delegate as! AppDelegate
            print(PFUser.current()?.username)
            appDelgate.initSinchClient(PFUser.current()!["username"] as! String)
            
            self.window = UIWindow.init(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let viewController = storyboard.instantiateViewController(withIdentifier: "RevealController")
            
            self.window!.rootViewController = viewController;
            self.window!.makeKeyAndVisible()
            
        }
        
        
        return true
    }
    

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.push!.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
//
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.push!.application(application, didReceiveRemoteNotification: userInfo)
    }
//
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        if self.sinchClient == nil {
            let userId = UserDefaults.standard.object(forKey: "userId") as? String
            if (userId != nil) {
                self.initSinchClient(userId!)
            }
        }
        self.sinchClient?.relayRemotePushNotification(userInfo)
    }
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable: Any]!, forType pushType: String!) {
        self.handleRemoteNotification(payload)
    }
    
//    func saveMessageOnParse(message: SINMessage) {
//        let query = PFQuery(className: "SinchMessage")
//        query.whereKey("messageId", equalTo: message.messageId)
//        query.findObjectsInBackgroundWithBlock() {(messageArray: [PFObject]?, error: NSError?) -> Void in
//            if (error == nil) {
//                // If the SinchMessage is not already saved on Parse (an empty array is returned), save it.
//                let messageObject = [PFObject(className: "SinchMessage")]
//                do {
//                    if messageArray?.count <= 0 {
//                        //This is where I changed the code!!!!!!!
//                        messageObject[0]["messageId"] = message.messageId
//                        messageObject[0]["owner"] = PFUser.currentUser()?.username!
//                        messageObject[0]["senderId"] = message.senderId
//                        messageObject[0]["recipientId"] = message.recipientIds[0]
//                        messageObject[0]["text"] = message.text
//                        messageObject[0]["timeStamp"] = message.timestamp
//                    }
//                    try PFObject.saveAll(messageObject)
//                }
//                catch {
//                    
//                }
//            } else {
//                print("Error: " + (error?.description)!)
//            }
//        }
//    }
    
    func initSinchClient(_ userID: String){
        self.sinchClient = Sinch.client(withApplicationKey: configvars.SINCH_APPLICATION_KEY, applicationSecret: configvars.SINCH_APPLICATION_SECRET, environmentHost: configvars.SINCH_ENVIORMENT_HOST, userId: userID)
        print("Sinch Version: " + Sinch.version() + " userid: " + userID)
        self.sinchClient!.setSupportMessaging(true)
        self.sinchClient!.setSupportActiveConnectionInBackground(true)
        self.sinchClient!.enableManagedPushNotifications()
        self.sinchClient!.start()
        self.sinchClient!.startListeningOnActiveConnection()
        
        self.sinchClient!.delegate = self
    }
    
    func clientDidStart(_ client: SINClient!) {
        print("Start SINClient successful!")
        self.sinchMessageClient = self.sinchClient?.messageClient()
        self.sinchMessageClient?.delegate = self
    }
    
    func clientDidFail(_ client: SINClient!, error: NSError!) {
        print("Start SINClient failed. Description: " + error.localizedDescription + ". Reason: %@." + error.localizedFailureReason!)
    }
    
    func messageClient(_ messageClient: SINMessageClient!, didReceiveIncomingMessage message: SINMessage!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: configvars.SINCH_MESSAGE_RECIEVED), object: self, userInfo: ["message" : message])
        
    }
    
    func messageSent(_ message: SINMessage!, recipientId: String!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: configvars.SINCH_MESSAGE_SENT), object: self, userInfo: ["message" : message])
        saveMessageOnParse(message)
    }
    
    func messageFailed(_ message: SINMessage!, info messageFailureInfo: SINMessageFailureInfo!) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: configvars.SINCH_MESSAGE_FAILED), object: self, userInfo: ["message" : message])
        
        //print("MessageBoard: message to " + messageFailureInfo.recipientId + " failed. Description: " + messageFailureInfo.error.localizedDescription + ". Reason: " + messageFailureInfo.error.localizedFailureReason)
    }
    
    func messageDelivered(_ info: SINMessageDeliveryInfo!) {
            NotificationCenter.default.post(name: Notification.Name(rawValue: configvars.SINCH_MESSAGE_FAILED), object: info)
    }
    
    
    func sendTextMessage(_ messageText: String, recipientID: String) {
        let outGoingMessage = SINOutgoingMessage(recipient: recipientID, text: messageText)
        self.sinchClient?.messageClient().send(outGoingMessage)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

