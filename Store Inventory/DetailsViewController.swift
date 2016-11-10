//
//  DetailsViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/10/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class DetailsViewController: ShowProductViewController {
    // Product Detail View Elements
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionLabel: UITextView!
    @IBOutlet var favoritesButton: UIButton!
    @IBOutlet var inStockLabel: UILabel!
    @IBOutlet var imageLabel: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    // Color Dropdown Elements
    @IBOutlet var chooseColorButton: UIButton!
    @IBOutlet var chooseColorLabel: UILabel!
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    // Action when a user touches inside the Add to Favorites button
    @IBAction func favoritesButtonClicked(sender: UIButton) {
        // Save new favorite if not a guest
        if (!prefs.boolForKey("ISGUESTUSER")) {
            FIRDatabase.database().reference().child("users/\(prefs.stringForKey("USERID"))/Favorites").child(currentProduct.productID as String).setValue(currentProduct?.title)
        }
        else {
            let errorAlert = UIAlertView(title: "Favorites Error", message: "Sorry, guests cannot store favorites.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    // Action when a user touches inside the 'Choose Color' text
    @IBAction func colorMenuSelected(sender: AnyObject) {
        let sheet = createCustomerColorMenu()
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            sheet.showFromRect(sender.frame, inView: self.view, animated: true)
        } else {
            sheet.showInView(self.view)
        }
    }
    
    // Size Dropdown Elements
    @IBOutlet var chooseSizeLabel: UILabel!
    @IBOutlet var chooseSizeButton: UIButton!
    
    // Action when a user touches inside the 'Choose Size' text
    @IBAction func sizeMenuSelected(sender: AnyObject) {
        let sheet = createSizeMenu
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            sheet.showFromRect(sender.frame, inView: self.view, animated: true)
        } else {
            sheet.showInView(self.view)
        }
    }
    
    // Sets the choose size button title to the selected size on the action sheet
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet.tag == Constants.Sizes.menuTag) {
            actionSheetButtonClicked(actionSheet, buttonIndex: buttonIndex, view: chooseSizeLabel)
            inStockLabel.text = calculateStock
        }
        else if (actionSheet.tag == Constants.Colors.menuTag) {
            actionSheetButtonClicked(actionSheet, buttonIndex: buttonIndex, view: chooseColorLabel)
        }
    }
    
    // Called when the product's details are finished loading from the database
    func updateWithLoadedData() {
        // Sets the view to display the current product's details
        titleLabel.text = currentProduct.title as String
        priceLabel.text = currentProduct.strPrice
        imageLabel.image = currentProduct.image
        self.descriptionLabel.text = self.currentProduct.productDescription as String
        
        indicator!.removeFromSuperview()
        inStockLabel.text = calculateStock
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide edit button if user is a Customer
        if (prefs.stringForKey("USERTYPE") == "Customer") {
            editButton.hidden = true
        }
        
        showLoadingSymbol(titleLabel)
        self.currentProduct.loadInformation(false, callback: updateWithLoadedData)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoEditing",
            let destination = segue.destinationViewController as? EditPagesViewController
        {
            destination.currentProduct = self.currentProduct
        }
    }
}
