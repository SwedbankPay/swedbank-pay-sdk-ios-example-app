//
//  StoreViewModelObserved.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-03.
//

import SwiftUI

/**
 A SwiftUI facade of the StoreViewModel
 */
class StoreViewModelObserved: ObservableObject {
    
    let model = StoreViewModel.shared
    
    @Published var showBasket = true
    @Published var processPayment = false
    
    @Published var enterPriceIsShown = false
    @Published var overideTotal: Decimal? = nil {
        didSet {
            
            StoreViewModel.shared.overrideTotal = overideTotal.map {
                (($0 * Decimal(100)) as NSDecimalNumber).intValue
            }
        }
    }
    @Published var overideTotalString = "" {
        didSet {
            overideTotal = overideTotalString.isEmpty ? nil : Decimal(string: overideTotalString, locale: .current)
        }
    }
    
    func removeFromBasket(_ product: Product) {
        model.removeFromBasket(product)
        objectWillChange.send()
    }
    
    var shippingCostLabel: String {
        let currency = ConsumerViewModel.shared.getCurrency()
        return "\(StoreViewModel.shared.getShippingCost() / 100) \(currency.rawValue)"
    }
    
    var total: Decimal {
        let totalCents = model.getBasketTotalPrice()
        let total = Decimal(totalCents) / Decimal(100)
        return total
    }
    
    var totalPriceLabel: String {
        
        let totalCents = model.getBasketTotalPrice()
        let hasFraction = totalCents % 100 != 0
        let formatter = StoreViewModelObserved.currencyFormatter
        formatter.minimumFractionDigits = hasFraction ? 2 : 0
        formatter.maximumFractionDigits = hasFraction ? 2 : 0
        let formattedTotal = formatter.string(from: total as NSDecimalNumber) ?? ""
        return "\(formattedTotal) \(ConsumerViewModel.shared.getCurrency().rawValue)"
    }
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        return formatter
    }()
}

