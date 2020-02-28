//
//  ShoppingCartHeaderView.swift
//  Example-app
//
//  Created by Pertti Kroger on 25.2.2020.
//  Copyright © 2020 Swedbank. All rights reserved.
//

import UIKit

class ShoppingCartHeaderCell : UITableViewCell {
    var onClosePressed: (() -> Void)?
    
    @IBAction func closeShoppingCartButtonClick(_ sender: Any) {
        onClosePressed?()
    }
}
