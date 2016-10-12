//
//  ProductTableViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/10/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

// MULTIPLE SECTIONS FOR CLOTHING TYPES
// Make sure to not show products with negative prices
// only load products when row method thing called

class ProductTableViewController: UITableViewController {

    var products = [Product]()
    var dataRef: FIRDatabaseReference!
    let detailSegueIdentifier = "ProductDetailsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
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
        // Dispose of any resources that can be recreated.
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
        cell.priceLabel.text = "$" + currentProduct.strPrice
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
 
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
