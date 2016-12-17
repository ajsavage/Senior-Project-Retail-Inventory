//
//  UpdateStoreInfoViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/14/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class UpdateStoreInfoViewController: Helper {
    //Properties
    @IBOutlet weak var storeNameLabel: UITextView!
    @IBOutlet weak var storeHoursLabel: UITextView!
    
    // reference to store info in the database
    var storeRef: FIRDatabaseReference? = nil
    
    // Saves the updateed information
    @IBAction func SaveButtonClicked(sender: AnyObject) {
        var temp: String = storeHoursLabel.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Checks if there is entered hours
        if temp != "" {
            storeRef?.child("Hours").setValue(temp)
        }
        
        temp = storeNameLabel.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        // Checks if there is an entered name
        if temp != "" {
            storeRef?.child("Name").setValue(temp)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Cancels updating
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Called when a textView is selected for editing
    override func textViewDidBeginEditing(textView: UITextView) {
        if (textView.tag == 2) {
            animateScrollView(storeHoursLabel, distanceLength: 150, up: true)
        }
    }
    
    // Called when a textView is being edited and the Return key is pushed
    override func textViewDidEndEditing(textView: UITextView) {
        if (textView.tag == 2) {
            animateScrollView(storeHoursLabel, distanceLength: 150, up: false)
        }
    }
    
    // Overrides the viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissTextFieldsByTapping()
        
        showLoadingSymbol(storeNameLabel)
        storeRef = FIRDatabase.database().reference().child("storeInfo")
        
        // Loads the current store info from database
        storeRef!.observeSingleEventOfType(
            .Value, withBlock: { snapshot in
                if snapshot.exists() {
                    if let temp = snapshot.childSnapshotForPath("Hours").value as? String {
                        self.storeHoursLabel.text = temp
                    }
                    
                    if let temp = snapshot.childSnapshotForPath("Name").value as? String {
                        self.storeNameLabel.text = temp
                    }
                }
                
                self.indicator?.removeFromSuperview()
        })
    }
}
