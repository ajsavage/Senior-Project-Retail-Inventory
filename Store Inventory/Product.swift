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
    private var _title: NSString! = "Default Product"
    private var _image: UIImage!
    private var _description: NSString?
    
    private var _price: Float! = -1
    private var _type: NSString?
    private var _id: NSString! = "AAA000"
    
    private var _colors = [NSString]()
    private var _sizes = [NSNumber]()
    
    private var _selfRef: FIRDatabaseReference!
    private var _loadedDetails = false
    private var _notLoadedMessage = "Attempting to access a Product that has not loaded the details from the database."
    
    override init() {
        super.init()
        _selfRef = FIRDatabase.database().reference().child("defaultProduct")
        _image = UIImage(named: "DefaultImage")
    }
    
    init(data: FIRDataSnapshot, ref: FIRDatabaseReference) {
        super.init()
        loadFromSnapshot(data, dataRef: ref)
    }
    
    private func loadFromSnapshot(data: FIRDataSnapshot, dataRef: FIRDatabaseReference) {
        _title = data.childSnapshotForPath("Title").value as? String
        _price = data.childSnapshotForPath("Price").value as? Float
        _id = data.key
        _selfRef = dataRef.child(data.key)
        
        getImageFromStorage()
    }
    
    var hasDetailsLoaded: Bool {
        return _loadedDetails
    }

    func loadDetails() {
        if _selfRef == nil { return }
        
        _selfRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists() { return }
            
           self._type = snapshot.valueForKey("Type") as? NSString
            self._description = snapshot.valueForKey("Description") as? NSString
            if self._description == nil {
                self._description = " "
            }
        
            //Sizes
            let sRef = snapshot.childSnapshotForPath("Sizes")
            self._sizes.append(sRef.valueForKey("XSmall") as! NSNumber)
            self._sizes.append(sRef.valueForKey("Small") as! NSNumber)
            self._sizes.append(sRef.valueForKey("Medium") as! NSNumber)
            self._sizes.append(sRef.valueForKey("Large") as! NSNumber)
            self._sizes.append(sRef.valueForKey("XLarge") as! NSNumber)
        
            //Colors
            for newColor in snapshot.childSnapshotForPath("Colors").children {
                self._colors.append(newColor.value)
            }
        })
        
        _loadedDetails = true
    }
    
    private func getImageFromStorage() {
        let storage = FIRStorage.storage().referenceForURL("gs://storeinventoryapp.appspot.com")
        let newImage = storage.child(_id as String + ".jpeg")
        
        newImage.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                self._image = UIImage(named: "DefaultImage")!
            }
            else {
                self._image = UIImage(data: data!)
            }
        }
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
    
    var productDescription: NSString! {
        if (!_loadedDetails) {
            print(_notLoadedMessage)
        }
        
        if _description == nil {
            return ""
        }
        else {
            return _description
        }
    }
    
    var strPrice: String {
        return NSString(format: "%.2f", _price) as String
    }
    
    var price: Float {
        return _price
    }
    
    var type: NSString! {
        if (!_loadedDetails) {
            print(_notLoadedMessage)
            _type = "Shirt"
        }
        
        return _type
    }
    
    var productID: NSString {
        return _id
    }
    
    var colors: Array<NSString> {
        if (!_loadedDetails) {
            print(_notLoadedMessage)
        }
        
        return _colors
    }
    
    var sizes: Array<NSNumber> {
        if (!_loadedDetails) {
            print(_notLoadedMessage)
        }
        
        if (_sizes.count != 5) {
            return [0, 0, 0, 0, 0]
        }
        
        return _sizes
    }
    
}
