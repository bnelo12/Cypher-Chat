//
//  DocumentViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 3/29/16.
//  Copyright © 2016 Elo Technology Sciences. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    @IBOutlet weak var documentNameLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    var documentURLString: String?
    var documentName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.documentNameLabel.text = documentName!
        
        let path = Bundle.main.path(forResource: documentURLString, ofType: nil)
        
        // Create an NSURL object based on the file path.
        let url = URL(fileURLWithPath: path!)
        
        // Create an NSURLRequest object.
        let request = URLRequest(url: url)
        
        // Load the web viewer using the request object.
        webView.loadRequest(request)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent;
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
