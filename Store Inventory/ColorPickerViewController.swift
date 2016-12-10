//
//  ColorPickerViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/5/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker

class ColorPickerViewController: UIViewController {
    //Properties
    @IBOutlet weak var mainView: UIView!
    
    // Delegate to whom to give the chosen color
    var delegate: AddNewColorViewController?
    
    // Color Picker view
    var colorPicker: SwiftHSVColorPicker?
    
    // Button Actions
    @IBAction func SelectButtonPushed(sender: AnyObject) {
        delegate?.chosenColor = colorPicker?.color
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        colorPicker = SwiftHSVColorPicker(frame: CGRectMake(10, 20, 300, 400))
        colorPicker!.setViewColor(UIColor.blueColor())
        
        // Forces the views to load
        _ = self.view
        
        mainView.addSubview(colorPicker!)
    }
   }
