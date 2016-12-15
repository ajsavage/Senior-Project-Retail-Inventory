//
//  Details.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/21/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class Details: NSObject {
    //Details Properties
    private var _description: NSString?
    private var _type: NSString?
    private var _colors = [ColorInventory]()
    private var _sizes = [NSNumber]()
    
    // Creates default details
    override init() {
        super.init()
        _description = "These are the default details"
    }
    
    // Creates product details from the given dictionary
    init(dictionary: NSDictionary) {
        super.init()
        
        _description = dictionary["Description"] as! String
        _type = dictionary["Type"] as! String
        
        if (dictionary["Colors"] as? NSDictionary) != nil {
            handleColors(dictionary["Colors"] as! NSDictionary)
        }
     
        if (dictionary["Sizes"] as? NSDictionary) != nil {
            sizesFromDictionary(dictionary["Sizes"] as! NSDictionary)
        }
    }
    
    // Creates a product from the given snapshot information
    init(ref: FIRDatabaseReference!, callback: () -> ()) {
        super.init()
        
        ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists() { return }
            
            self._type = snapshot.childSnapshotForPath("Type").value as? NSString
            
            self._description = snapshot.childSnapshotForPath("Description").value as? NSString
            
            //Sizes
            let sRef = snapshot.childSnapshotForPath("Sizes")
            self._sizes.append(sRef.childSnapshotForPath("XSmall").value as! NSNumber)
            self._sizes.append(sRef.childSnapshotForPath("Small").value as! NSNumber)
            self._sizes.append(sRef.childSnapshotForPath("Medium").value as! NSNumber)
            self._sizes.append(sRef.childSnapshotForPath("Large").value as! NSNumber)
            self._sizes.append(sRef.childSnapshotForPath("XLarge").value as! NSNumber)
            
            //Colors
            if let colorDict = snapshot.childSnapshotForPath("Colors").value as? NSDictionary {
                self.handleColors(colorDict)
            }
            
            // Update view
            callback()
        })
    }
    
    // Reads all of the sizes from the dictionary into an array
    private func sizesFromDictionary(dict: NSDictionary) -> Array<Int> {
        var array = Array<Int>()

        for name in Constants.Sizes.Names {
            array.append(sizesHelper(dict, name: name))
        }
        
        return array
    }
    
    private func sizesHelper(dict: NSDictionary, name: String) -> Int {
        if let temp = dict.valueForKey(name) as? String {
            return Int(temp) != nil ? Int(temp)! : 0
        }
        
        return 0
    }
    
    // Store all of the colorInventories from the dictionary
    private func handleColors(dictionary: NSDictionary) {
        // Loop through each color type with colors
        for unconvertedKey in dictionary.allKeys {
            let type: String = unconvertedKey as? String != nil ?
                unconvertedKey as! String : "error"
            let typeKey: NSDictionary? = dictionary.objectForKey(unconvertedKey) as? NSDictionary
            
            if typeKey != nil {
                // Loop through each color that exists in this color type
                for unconvertedName in typeKey!.allKeys {
                    let name: String = unconvertedName as? String != nil ?
                        unconvertedName as! String : "error"
                    let nameKey: NSDictionary? = dictionary.objectForKey(unconvertedName) as? NSDictionary
                    
                    // If color exists, create a new ColorInventory object
                    if nameKey != nil {
                        let temp: ColorInventory = ColorInventory(name: name, type: type,
                                                                  newSizes: sizesFromDictionary(nameKey!))
                        _colors.append(temp)
                    }
                }
            }
        }
    }
    
    // Returns the colorinventory value with the given color name
    func getInventoryOf(colorName: String) -> ColorInventory? {
        var inventory: ColorInventory? = nil
        
        for testInventory in colors {
            if (testInventory.colorName == colorName) {
                inventory = testInventory
            }
        }
        
        return inventory
    }
    
    var productDescription: NSString! {
        if _description == nil {
            return ""
        }
        else {
            return _description
        }
    }
    
    var type: NSString! {
        if _type == nil {
            _type = "Shirt"
        }
        
        return _type
    }
    
    var colors: Array<ColorInventory> {
        return _colors
    }
    
    var sizes: Array<NSNumber> {
        if (_sizes.count != 5) {
            return [0, 0, 0, 0, 0]
        }
        
        return _sizes
    }

}
