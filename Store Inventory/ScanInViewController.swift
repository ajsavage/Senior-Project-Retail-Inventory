//
//  ScanInViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/28/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class ScanInViewController: ShowProductViewController, barcodeScannerCommunicator {
    @IBOutlet var scanInButton: UIButton!
    @IBOutlet var overallScrollView: UIScrollView!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var barcodeLabel: UILabel!
    @IBOutlet weak var inventoryCountField: UITextField!
    @IBOutlet weak var editInventoryButton: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    
    // Database reference
    let dataRef = FIRDatabase.database().reference()
    
    // Barcode back from scanner
    var barcode: String?
    
    // Barcode specific data
    var color: String! = ""
    var size: String! = ""
    var colorInventory: ColorInventory? = nil
    
    // If a first barcode has been scanned
    var isFirstTime: Bool = false
    
    // Current inventory count
    var currentCount: Int = 0
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        showLoadingSymbol(sender as! UIButton)
        
        if currentProduct != nil {
            colorInventory!.updateSize(size, count: currentCount)
            dataRef.child("inventory/\(currentProduct.productID)/Colors/\(colorInventory!.colorType)")
                .child(color).child(size).setValue(currentCount)
        }
        
        indicator?.removeFromSuperview()
    }
    
    @IBAction func scanButtonClicked(sender: UIButton) {
        if !isFirstTime {
            saveButtonClicked(scanInButton)
        }
        
        showLoadingSymbol(sender)
        
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }

    @IBAction func plusClicked(sender: AnyObject) {
        currentCount += 1
        inventoryCountField.text = String(currentCount)
    }
    
    @IBAction func minusClicked(sender: AnyObject) {
        if (currentCount > 0) {
            currentCount -= 1
            inventoryCountField.text = String(currentCount)
        }
    }
    
    // Barcode scanner callback
    func backFromBarcodeScanner(barcode: String?, index: Int) {
        self.barcode = barcode
        
        if (barcode != nil) {
            barcodeLabel.text = "Barcode: \(self.barcode)"
            
            dataRef.child("barcodeIDs/\(barcode)").observeSingleEventOfType(.Value, withBlock: { snapshot in
                if !snapshot.exists() {
                    self.showSearchAlert("Barcode #" + barcode! + " does not currently exist in the database.")
                }
                else {
                    self.color = snapshot.valueForKey("Color") as? String
                    self.size = snapshot.valueForKey("Size") as? String
                    let id = snapshot.valueForKey("Product") as? String
                    
                    self.dataRef.child("inventory/\(id)").observeSingleEventOfType(.Value, withBlock: { snapshot in
                        if !snapshot.exists() {
                            self.showSearchAlert("Product #" + id! + " does not currently exist in the database.")
                        }
                        else {
                            self.currentProduct = Product(data: snapshot, ref: self.dataRef.child("inventory"))
                            self.currentProduct.loadInformation(true, callback: self.updateWithLoadedData)
                        }
                    })
                }
            })
        }
    }
    
    // Called when the product's details are finished loading from the database
    func updateWithLoadedData() {
        colorInventory = currentProduct.getInventoryOf(color)
        
        // Check for non-existent barcode
        if (colorInventory == nil) {
            showErrorAlert("Color does not Exist", message: "Product does not have this color anymore")
            return
        }
        
        // Show hidden views if loaded first barcode
        if (isFirstTime) {
            mainView.hidden = false
            editInventoryButton.hidden = false
            scanInButton.setTitle("Save and Scan More Barcodes", forState: .Normal)
        }
        
        currentCount = colorInventory!.sizes[Constants.Sizes.Names.indexOf(size)!]
        colorLabel.text = color
        sizeLabel.text = size
        titleLabel.text = currentProduct.title as String
        imageView.image = currentProduct.image
        inventoryCountField.text = String(currentCount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFirstTime = true
        editInventoryButton.hidden = true
        mainView.hidden = true
    }
    
    override func textFieldDidEndEditing(textField: UITextField) {
        let string = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let newCount: Int? = Int(string)
        
        if (newCount != nil && newCount >= 0) {
            currentCount = newCount!
        }
        else {
            showErrorAlert("Invalid Inventory Count", message: "Please enter a valid integer greater than zero.")
            inventoryCountField.becomeFirstResponder()
        }
    }
}
