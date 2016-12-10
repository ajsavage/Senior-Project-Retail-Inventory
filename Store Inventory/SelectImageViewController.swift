//
//  SelectImageViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/5/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class SelectImageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    // Calling delegate
    var delegate: AddProductViewController? = nil

    // Button Actions
    @IBAction func takePhotoPushed(sender: AnyObject) {
    }
    
    @IBAction func selectPhotoPushed(sender: AnyObject) {
    }
    
    @IBAction func cancelButtonPushed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
