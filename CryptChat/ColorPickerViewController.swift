//
//  ColorPickerViewController.swift
//  Cypher Chat
//
//  Created by Benjamin Elo on 4/7/16.
//  Copyright © 2016 Elo Technology Sciences. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker

class ColorPickerViewController: UIViewController {
    @IBOutlet weak var colorPicker: SwiftHSVColorPicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.setViewColor(UIColor.red)
    }
}
