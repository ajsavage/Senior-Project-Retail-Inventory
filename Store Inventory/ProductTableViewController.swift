//
//  ProductTableViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/10/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class ProductTableViewController: UITableViewController {
    @IBOutlet weak var navigationTitle: UINavigationItem!
    
    // NSUserDefaults
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var products = [Product]()
    let detailSegueIdentifier = "ProductDetailsSegue"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationTitle.title = "Hi " + prefs.stringForKey("USERNAME")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataRef = FIRDatabase.database().reference().child("inventory")
        var newProduct: Product!
        
        // Set back button title
        let backButton = UIBarButtonItem.init(title: "Home", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        dataRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if !snapshot.exists() { return }
            
            for child in snapshot.children {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    let converted = child as! FIRDataSnapshot
                    newProduct = Product(data: converted, ref: dataRef)
                    
                    if (newProduct.price > 0) {
                        self.products.append(newProduct)
                        self.loadProductImageFromStorage(newProduct)
                    }
                }
            }
        })
    }
    
    func loadProductImageFromStorage(product: Product) {
        let storage = FIRStorage.storage().referenceForURL("gs://storeinventoryapp.appspot.com")
        let newImage = storage.child(product.productID as String + ".jpeg")
        
        newImage.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                if (error != nil) {
                    product.setImage(UIImage(named: "DefaultImage")!)
                }
                else {
                    product.setImage(UIImage(data: data!)!)
                }
            
                self.tableView.reloadData()
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ProductTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ProductTableViewCell
        let currentProduct = products[indexPath.row]
        
        cell.productTitle.text = currentProduct.title as String
        cell.priceLabel.text = currentProduct.strPrice
        cell.productImage.image = currentProduct.image
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == detailSegueIdentifier,
            let destination = segue.destinationViewController as? DetailsViewController,
            IDIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.currentProduct = products[IDIndex]
        }
    }
}
