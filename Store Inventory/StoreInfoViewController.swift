//
//  StoreInfoViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/21/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class StoreInfoViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        usernameLabel.text = "Hi \(prefs.stringForKey("USERNAME"))! Welcome to"
        
        FIRDatabase.database().reference().child("storeInfo").observeSingleEventOfType(
            .Value, withBlock: { snapshot in
            if snapshot.exists() {
                if let temp = snapshot.valueForKey("Hours") as? String {
                    self.hoursLabel.text = temp
                }
                
                if let temp = snapshot.valueForKey("Name") as? String {
                    self.storeNameLabel.text = temp
                }
            }
        })
    }
}
