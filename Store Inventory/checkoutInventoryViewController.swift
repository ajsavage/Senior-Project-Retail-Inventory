//
//  checkoutInventoryViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 12/14/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import FirebaseDatabase

class checkoutInventoryViewController: Helper, barcodeScannerCommunicator {
    // Properies
    @IBOutlet weak var barcodesScrollView: UIScrollView!
    
    // Holds all of the barcodes
    var barcodeArray = Array<String>()
    
    // Barcode Button Properties
    let barcodeButtonHeight = 25
    var nextYValue = 0
    
    // Checkoout properties
    var color: String? = nil
    var size: String? = nil
    var id: String? = nil
    var type: String? = nil
    
    // Database Reference
    let dataRef: FIRDatabaseReference = FIRDatabase.database().reference()
    
    @IBAction func scanOutButton(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    @IBAction func checkoutButtonClicked(sender: AnyObject) {
        showLoadingSymbol(barcodesScrollView)
        
        for barcode in barcodeArray {
            dataRef.child("barcodeIDs/\(barcode)").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.exists() {
                    self.id = snapshot.valueForKeyPath("Product") as? String
                    self.color = snapshot.valueForKeyPath("Color") as? String
                    self.size = snapshot.valueForKeyPath("Size") as? String
                    self.checkoutInventory(1)
                }
            })
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func CancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Helper method for checking out products
    private func checkoutInventory(quantity: Int) {
        if (id != nil && color != nil && size != nil) {
            dataRef.child("colors/\(color)").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.exists() {
                    self.type = snapshot.valueForKeyPath("Type") as? String
                    
                    if self.type != nil {
                        let path = self.dataRef.child("Inventory/\(self.id)/Colors/\(self.type)/\(self.color)")
                        
                        path.observeEventType(.Value, withBlock: { snapshot in
                            if snapshot.exists(){
                                if var currentInventory = snapshot.valueForKeyPath(self.size!) as? Int {
                                    if (currentInventory > 0) {
                                        currentInventory -= quantity
                                    }
                        
                                    path.child(self.size!).setValue(currentInventory)
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    // Function called by the barcode scanner when scan is completed
    func backFromBarcodeScanner(barcode: String?, index: Int) {
        if (barcode != nil) {
            dataRef.child("barcodeIDs/\(barcode)").observeEventType(.Value,
                withBlock: { snapshot in
                
                if snapshot.exists() {
                    if let id = snapshot.valueForKeyPath("Product") as? String {
                        var title = "Barcode: \(barcode) for \(id)"
                        
                        let temp = snapshot.valueForKeyPath("Color") as? String
                        let temp2 = snapshot.valueForKeyPath("Size") as? String
                        if (temp != nil && temp2 != nil) {
                            title = title + "\nA \(temp) \(temp2)"
                        }
                        
                        self.setupBarcodeView(barcode!, title: title)
                    }
                }
                // Notify user barcode is currently not in the database
                else {
                    self.showErrorAlert("Barcode Error", message: "Barcode #\(barcode) is currently not in the database.")
                }
            })
        }
    }
    
    // Sets up color swatch
    private func setupBarcodeView(barcode: String, title: String) {
        barcodeArray.append(barcode)
        
        // Create new barcode button
        let barcodeButton = UIButton()
        var addHeight = 0
        barcodeButton.frame = CGRect(x: 0, y: nextYValue, width: Int(barcodesScrollView.bounds.width),
                                     height: barcodeButtonHeight)
        
        barcodeButton.setTitle(title, forState: .Normal)
        barcodeButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        // Calculate addHeight, which is the height of a color swatch
        // plus extra space unless on the first row
        if nextYValue == 0 {
            addHeight = barcodeButtonHeight
        }
        else {
            addHeight = barcodeButtonHeight + 10
        }
        
        // Extend scrollView
        let currentSize = barcodesScrollView.contentSize
        barcodesScrollView.contentSize = CGSize(width: currentSize.width, height: currentSize.height + CGFloat(addHeight))
      
        // Move down values
        nextYValue += addHeight
        barcodesScrollView.addSubview(barcodeButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
