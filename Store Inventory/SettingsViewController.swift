//
//  SettingsViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/12/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBAction func CancelButtonAction(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(<#T##flag: Bool##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
    
    @IBAction func SaveButtonAction(sender: UIBarButtonItem) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
