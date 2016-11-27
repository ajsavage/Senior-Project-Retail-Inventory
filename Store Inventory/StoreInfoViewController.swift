//
//  StoreInfoViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 11/21/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class StoreInfoViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        usernameLabel.text = "Hi \(prefs.stringForKey("USERNAME"))!"
    }
}
