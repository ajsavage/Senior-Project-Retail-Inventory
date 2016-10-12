//
//  DetailsViewController.swift
//  Store Inventory
//
//  Created by Andrea Savage on 10/10/16.
//  Copyright © 2016 Andrea Savage. All rights reserved.
//

import UIKit
import Firebase

class DetailsViewController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var imageLabel: UIImageView!
    @IBOutlet var descriptionLabel: UITextView!
    @IBOutlet var colorLabel: UITextField!
    @IBOutlet var sizeLabel: UITextField!
    @IBOutlet var inStockLabel: UILabel!
    
    @IBOutlet var favoritesButton: UIButton!
    var currentProduct: Product!
    
    override func viewWillAppear(animated: Bool) {
//USE this?? also need to reload after firebase thing and do in background thread thingy
        if (!currentProduct.hasDetailsLoaded) {
            currentProduct.loadDetails()
        }
        
        titleLabel.text = currentProduct.title as String
        priceLabel.text = "$" + currentProduct.strPrice
        
        descriptionLabel.text = currentProduct.productDescription as String
        imageLabel.image = currentProduct.image
        
        let stock = 3
        inStockLabel.text = "In Stock: " + String(stock)
        //favoritesButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
