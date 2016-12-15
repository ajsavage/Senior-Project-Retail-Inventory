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
    
    @IBAction func SaveButtonClicked(sender: AnyObject) {
        var temp: String = storeHoursLabel.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if temp != "" {
            storeRef?.child("Hours").setValue(temp)
        }
        
        temp = storeNameLabel.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        if temp != "" {
            storeRef?.child("Name").setValue(temp)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingSymbol(storeNameLabel)
        storeRef = FIRDatabase.database().reference().child("storeInfo")
        
        storeRef!.observeSingleEventOfType(
            .Value, withBlock: { snapshot in
                if snapshot.exists() {
                    if let temp = snapshot.valueForKey("Hours") as? String {
                        self.storeHoursLabel.text = temp
                    }
                    
                    if let temp = snapshot.valueForKey("Name") as? String {
                        self.storeNameLabel.text = temp
                    }
                }
                
                self.indicator?.removeFromSuperview()
        })
    }
}
