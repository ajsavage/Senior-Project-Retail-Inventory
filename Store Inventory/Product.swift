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
    
    // Holds a dictionary to load from if needed
    private var _dictionary: NSDictionary = [:]
    
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
    
    // Creates a new product
    init(dict: NSDictionary, newImage: UIImage?) {
        super.init()
        
        // Sets main data values
        _id = dict["ID"] as! String
        _title = dict["Title"] as! String
        _price = dict["Price"] as! Float
        _detailsRef = Details(dictionary: dict)
        _dictionary = dict
        _selfRef = FIRDatabase.database().reference().child("inventory").child(_id as String)
        
        // Checks if there is a product image available
        if (newImage == nil) {
            _image = UIImage(named: "DefaultImage")
        }
        else {
            _image = newImage
        }
        
        // Uploads the product
        loadProductToDatabase()
        
        // Uploads the image
        saveImage(_image, callback: noCallback)
    }
    
    // Creates a product from the given snapshot information
    init(data: FIRDataSnapshot, ref: FIRDatabaseReference) {
        super.init()
        loadFromSnapshot(data, dataRef: ref)
    }
    
    // Creates a product from a given product ID
    init(prodID: String) {
        super.init()
        
        _selfRef = FIRDatabase.database().reference().child("inventory/\(prodID)")
        _id = prodID
        
        // Downloads the main product data
        _selfRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
         
            if !snapshot.exists() { return }
          
            self._title = snapshot.childSnapshotForPath("Title").value as! String
            self._price = snapshot.childSnapshotForPath("Price").value as! Float
        })
        
        // Loads the product image
        getImageFromStorage(noCallback)
    }
    
    // Empty method used when callbacks are unnecessary
    private func noCallback() {
        
    }
    
    // Uploads the product to the Firebase database
    private func loadProductToDatabase() {
        let mutDictionary: NSMutableDictionary = _dictionary.mutableCopy() as! NSMutableDictionary
        mutDictionary.removeObjectForKey("ID")
        
        // sets the _selfRef location in the database to the current dictionary
        _selfRef.setValue(mutDictionary)
    }
    
    // Sets the product's overview information
    private func loadFromSnapshot(data: FIRDataSnapshot, dataRef: FIRDatabaseReference) {
        _title = data.childSnapshotForPath("Title").value as? String
        _price = data.childSnapshotForPath("Price").value as? Float
        _selfRef = dataRef.child(data.key)
        _id = data.key
    }
    
    // Loads all of the product's information from the database at the selfRef location
    func loadInformation(loadImage: Bool, callback: () -> ()) {
        // Checks if the product's information already exists
        if _selfRef != nil && _detailsRef == nil {
            // Checks if the image still needs to be loaded
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
    
    // Loads the image from Firebase Storage saved under the product's id number
    // or the default image if not available
    func getImageFromStorage(callback: () -> ()) {
        let storage = FIRStorage.storage().referenceForURL("gs://storeinventoryapp.appspot.com")
        let newImage = storage.child(_id as String + ".jpeg")
        
        // Accesses Firebase Storage
        newImage.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            // Checks if no image exists
            if (error != nil) {
                self._image = UIImage(named: "DefaultImage")!
            }
            else {
                self._image = UIImage(data: data!)
            }
            
            self._detailsRef = Details(ref: self._selfRef, callback: callback)
        }
    }
    
    // Saves the new image to this product's location in storage
    func saveImage(image: UIImage, callback: () -> ()) {
        let data: NSData = UIImageJPEGRepresentation(image, 0)!
        let storage = FIRStorage.storage().referenceForURL("gs://storeinventoryapp.appspot.com")
        let newImage = storage.child(_id as String + ".jpeg")
        
        // Uploads the given image
        newImage.putData(data, metadata: nil) { metadata, error in
            if (error != nil) {
                print("Saving Product Image failed!")
            }
            
            callback()
        }
        
        callback()
    }
    
    // Returns the inventory count of a given color forthis product
    func getInventoryOf(colorName: String) -> ColorInventory? {
        return _detailsRef!.getInventoryOf(colorName)
    }
    
    // Changes this product's image
    func setImage(newImage: UIImage) {
        _image = newImage
    }
    
    // Returns the price as a String in $X.XX format
    var strPrice: String {
        return "$" + (NSString(format: "%.02f", _price) as String)
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
    
    var colors: Array<ColorInventory> {
        if _detailsRef == nil {
            return [ColorInventory]()
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
