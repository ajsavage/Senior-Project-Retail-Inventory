//
//  Product.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/9/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class Product: NSObject {
    // Product Properties
    private var _title: NSString! = "Default Product"
    private var _image: UIImage!
    private var _price: Float! = -1
    private var _id: NSString! = "AAA000"
    
    // Reference to this product in the database
    private var _selfRef: FIRDatabaseReference!
    
    // Reference to this product's details
    private var _detailsRef: Details? = nil
    
    // Creates a default product
    override init() {
        super.init()
        _selfRef = FIRDatabase.database().reference().child("defaultProduct")
        _image = UIImage(named: "DefaultImage")
    }
    
    // Creates a product from the given snapshot information
    init(data: FIRDataSnapshot, ref: FIRDatabaseReference) {
        super.init()
        loadFromSnapshot(data, dataRef: ref)
    }
    
    // Sets the product's overview information and loads the image from storage
    private func loadFromSnapshot(data: FIRDataSnapshot, dataRef: FIRDatabaseReference) {
        _title = data.childSnapshotForPath("Title").value as? String
        _price = data.childSnapshotForPath("Price").value as? Float
        _selfRef = dataRef.child(data.key)
        _id = data.key
    }

    // Loads all of the product's information from the database at the selfRef location
    func loadInformation(loadImage: Bool, callback: () -> ()) {
        if _selfRef != nil && _detailsRef == nil {
            if (loadImage) {
                getImageFromStorage(callback)
            }
            else {
                _detailsRef = Details(ref: _selfRef, callback: callback)
            }
        }
        else {
            callback()
        }
    }
    
    // Loads the image in storage saved under the product's id number 
    // or the default image if not available
    func getImageFromStorage(callback: () -> ()) {
        let storage = FIRStorage.storage().referenceForURL("gs://storeinventoryapp.appspot.com")
        let newImage = storage.child(_id as String + ".jpeg")
        
        newImage.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                self._image = UIImage(named: "DefaultImage")!
            }
            else {
                self._image = UIImage(data: data!)
            }
            
            self._detailsRef = Details(ref: self._selfRef, callback: callback)
        }
    }
    
    func setImage(newImage: UIImage) {
        _image = newImage
    }
    
    // Returns the price as a String in $X.XX format
    var strPrice: String {
        return "$" + (NSString(format: "%.2f", _price) as String)
    }
    
    var selfRef: FIRDatabaseReference! {
        return _selfRef
    }
    
    var title: NSString {
        return _title
    }
    
    var image: UIImage! {
        return _image
    }
    
    var price: Float {
        return _price
    }
    
    var productID: NSString {
        return _id
    }
    
    // Access the details
    var productDescription: NSString! {
        if _detailsRef == nil {
            return ""
        }
        else {
            return _detailsRef!.productDescription
        }
    }
    
    var type: NSString! {
        if _detailsRef == nil {
            return "Shirt"
        }
        else {
            return _detailsRef!.type
        }
    }
    
    var colors: Array<NSString> {
        if _detailsRef == nil {
            return [NSString]()
        }
        else {
            return _detailsRef!.colors
        }
    }
    
    var sizes: Array<NSNumber> {
        if _detailsRef == nil {
            return [NSNumber]()
        }
        else {
            return _detailsRef!.sizes
        }
    }
}
