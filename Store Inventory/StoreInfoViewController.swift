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

    // Overrides the viewWillAppear function
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let name: String! = prefs.stringForKey("USERNAME")!
        usernameLabel.text = "Hi \(name)! Welcome to"
        
        // Loads the current store info from database
        FIRDatabase.database().reference().child("storeInfo").observeSingleEventOfType(
            .Value, withBlock: { snapshot in
            if snapshot.exists() {
                // Hours
                if let temp = snapshot.childSnapshotForPath("Hours").value as? String {
                    self.hoursLabel.text = temp
                }
                
                // Name
                if let temp = snapshot.childSnapshotForPath("Name").value as? String {
                    self.storeNameLabel.text = temp
                }
            }
        })
    }
}
