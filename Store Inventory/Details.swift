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
    private var _colors = [NSString]()
    private var _sizes = [NSNumber]()
    
    // Creates default details
    override init() {
        super.init()
        _description = "These are the default details"
    }
    
    // Creates product details from the given dictionary
    init(dictionary: NSDictionary) {
        _description = dictionary["Description"] as! String
        _type = dictionary["Type"] as! String
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
            for newColor in snapshot.childSnapshotForPath("Colors").children {
                self._colors.append(newColor.value)
            }
            
            // Update view
            callback()
        })
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
    
    var colors: Array<NSString> {
        return _colors
    }
    
    var sizes: Array<NSNumber> {
        if (_sizes.count != 5) {
            return [0, 0, 0, 0, 0]
        }
        
        return _sizes
    }

}
