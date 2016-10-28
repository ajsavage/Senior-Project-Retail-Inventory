//
//  ProductCollectionViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/21/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class ProductCollectionViewController: UICollectionViewController {
    // Properties
    private var products = [Product]()
    private var dataRef: FIRDatabaseReference!
    
    private let reuseIdentifier = "ProductCollectionViewCell"
    private let detailSegueIdentifier = "ProductDetailsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
        // Register cell classes
        self.collectionView!.registerClass(ProductCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        //products = [Product(), Product(), Product()]
        loadProductsFromDatabase()
    }
    
    func loadProductsFromDatabase() {
        dataRef = FIRDatabase.database().reference().child("inventory")
        var newProduct: Product!
        
        dataRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.exists() { return }
            
            for child in snapshot.children {
                let converted = child as! FIRDataSnapshot
                newProduct = Product(data: converted, ref: self.dataRef)
                
                self.products.append(newProduct)
            }
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // NEEDS CODE - release all product's details OR just all not current viewed products?
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // NEEDS CODE - use sections for separate clothing types
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> ProductCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ProductCollectionViewCell
        let currentProduct = products[indexPath.row]
        
        cell.titleLabel.text = currentProduct.title as String
        cell.priceLabel.text = currentProduct.strPrice
        cell.imageLabel.image = currentProduct.image
        
        return cell
    }

    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

extension ProductCollectionViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        textField.addSubview(indicator)
        indicator.frame = textField.bounds
        indicator.startAnimating()
        
        // search asynchronously
        
        indicator.removeFromSuperview()
        
        // do a thing
        
        self.collectionView?.reloadData()
    
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}
