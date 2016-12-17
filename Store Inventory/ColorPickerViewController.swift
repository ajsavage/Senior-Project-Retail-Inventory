//
//  ColorPickerViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/13/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker

class ColorPickerViewController: UIViewController {
    // Properties
    @IBOutlet var mainView: UIView!
    
    // SwiftHSVColorPicker that allows the user to choose a color
    var colorPicker: SwiftHSVColorPicker? = nil
    
    // Delegate to return selected color to
    var delegate: AddNewColorViewController? = nil
    
    // Button Actions  
    @IBAction func selectButtonClicked(sender: AnyObject) {
        // Checks if a delegate exists
        if delegate != nil && colorPicker != nil {
            delegate?.newSelectedColor(colorPicker!.color)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }

    // Overrides the viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker = SwiftHSVColorPicker(frame: CGRectMake(10, 20, 300, 400))
        mainView.addSubview(colorPicker!)
        
        colorPicker!.setViewColor(UIColor.blueColor())
    }
}
