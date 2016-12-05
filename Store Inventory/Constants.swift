//
//  Constants.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/24/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit

class Constants: NSObject {
    struct ProductID {
        static let Length = 8
    }
    
    struct Types {
        static let Names = ["Shirt", "Pants", "Dress"]
        static let MenuTag = 3
        static let Filters = ["Shirt", "Pants", "Dress", "All"]
    }
    
    struct Sizes {
        static let XSmall = 0
        static let Small = 1
        static let Medium = 2
        static let Large = 3
        static let XLarge = 4
     
        static let MenuTag = 1
        
        static let Names = ["XSmall", "Small", "Medium", "Large", "XLarge"]
    }
    
    struct Colors {
        static let MenuTag = 2
        static let Names = ["White", "Gray", "Black", "Pink", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Brown"]
    }
    
    struct Description {
        static let FieldTag = 5
    }
    
    struct Paging {
        static let ItemNumber = 15
    }
}
