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
    
    // Scans a new barcode
    @IBAction func scanOutButton(sender: AnyObject) {
        let scanner = BarcodeScanner()
        scanner.delegate = self
        
        // Start barcode scanner
        self.presentViewController(scanner, animated: true, completion: nil)
    }
    
    // Reduces each scanned product's inventory by 1
    @IBAction func checkoutButtonClicked(sender: AnyObject) {
        showLoadingSymbol(barcodesScrollView)
        
        // Reduces each barcodes inventory by one
        for barcode in barcodeArray {
            // Loads barcode info from database
            dataRef.child("barcodeIDs/\(barcode)").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.exists() {
                    self.id = snapshot.childSnapshotForPath("Product").value as? String
                    self.color = snapshot.childSnapshotForPath("Color").value as? String
                    self.size = snapshot.childSnapshotForPath("Size").value as? String
                    self.checkoutInventory(1)
                }
            })
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Cancels view
    @IBAction func CancelButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Helper method for checking out products
    private func checkoutInventory(quantity: Int) {
        // Checks if the barcode info exists
        if (id != nil && color != nil && size != nil) {
            // Loads the relevant product from database
            dataRef.child("colors/\(color)").observeEventType(.Value, withBlock: { snapshot in
                if snapshot.exists() {
                    self.type = snapshot.childSnapshotForPath("Type").value as? String
                    
                    // Checks if the product has a type
                    if self.type != nil {
                        let path = self.dataRef.child("Inventory/\(self.id)/Colors/\(self.type)/\(self.color)")
                        
                        path.observeEventType(.Value, withBlock: { snapshot in
                            if snapshot.exists(){
                                if var currentInventory = snapshot.childSnapshotForPath(self.size!).value as? Int {
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
    func backFromBarcodeScanner(maybeBarcode: String?, index: Int) {
        // Check if the barcode exists
        if (maybeBarcode != nil) {
            let barcode: String = maybeBarcode!
            
            // Loads the barcode info
            dataRef.child("barcodeIDs/\(barcode)").observeEventType(.Value,
                withBlock: { snapshot in
                
                // Checks if the barcode info exists
                if snapshot.exists() {
                    if let id = snapshot.childSnapshotForPath("Product").value as? String {
                        var title = "Barcode: \(barcode) for \(id)"
                        
                        let temp = snapshot.childSnapshotForPath("Color").value as? String
                        let temp2 = snapshot.childSnapshotForPath("Size").value as? String
                        if (temp != nil && temp2 != nil) {
                            title = title + "\nA \(temp!) \(temp2!)"
                        }
                        
                        self.setupBarcodeView(barcode, title: title)
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
        let barcodeButton = UILabel()
        var addHeight = 0
        let width: Int? = Int(barcodesScrollView.bounds.width)
        barcodeButton.frame = CGRect(x: 0, y: nextYValue, width: width!,
                                     height: barcodeButtonHeight)
        
        barcodeButton.text = title
      //  barcodeButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
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
        barcodesScrollView.contentSize = CGSize(width: CGFloat(width!), height: currentSize.height + CGFloat(addHeight))
      
        // Move down values
        nextYValue += addHeight
        barcodesScrollView.addSubview(barcodeButton)
    }
    
    // Overrides the viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
