import UIKit

private func price(sek: Int, nok: Int) -> [Currency: Int] {
    #if PROD_DEMO
    return [
        Currency.SEK: 100,
        Currency.NOK: 100
    ]
    #else
    return [
        Currency.SEK: sek,
        Currency.NOK: nok
    ]
    #endif
}

/// Singleton ViewModel for store data
class StoreViewModel {
    
    static let shared = StoreViewModel()
    
    private init() {}
    
    private var basket: [Product] = []
    
    var overrideTotal: Int?
    
    /// Example static store data, normally this data would be provided by your backend
    let products: [Product] = [
        Product.init(
            id: NSUUID().uuidString.lowercased(),
            name: "Pink Sneakers",
            image: "Product-Pink-Sneakers",
            price: price(
                sek: 159900,
                nok: 148100
            ),
            vat: 25,
            highlightHexColor: 0xFFCFCF
        ),
        
        Product.init(
            id: NSUUID().uuidString.lowercased(),
            name: "Red Skate Shoes",
            image: "Product-Red-Skate-Shoes",
            price: price(
                sek: 99900,
                nok: 92500
            ),
            vat: 25,
            highlightHexColor: 0x9A2D3A
        ),
        
        Product.init(
            id: NSUUID().uuidString.lowercased(),
            name: "Red Sneakers",
            image: "Product-Red-Sneakers",
            price: price(
                sek: 189900,
                nok: 176000
            ),
            vat: 25,
            highlightHexColor: 0xF0312D
        ),
        
        Product.init(
            id: NSUUID().uuidString.lowercased(),
            name: "Yellow Skate Shoes",
            image: "Product-Yellow-Skate-Shoes",
            price: price(
                sek: 89900,
                nok: 83300
            ),
            vat: 25,
            highlightHexColor: 0xF4B800
        ),
        
        Product.init(
            id: NSUUID().uuidString.lowercased(),
            name: "Grey Sneakers",
            image: "Product-Grey-Sneakers",
            price: price(
                sek: 249900,
                nok: 231600
            ),
            vat: 25,
            highlightHexColor: 0xD0D0D0
        )
    ]
    
    /// Example shipping cost values for both countries
    var shippingCost: [Currency: Int] {
        #if PROD_DEMO
        return [
            Currency.NOK: 0,
            Currency.SEK: 0
        ]
        #else
        return [
            Currency.NOK: 12000,
            Currency.SEK: 12700
        ]
        #endif
    }
    
    // MARK: Shopping Basket
    
    /// Returns number of items in the shopping basket
    func getBasketCount() -> Int {
        return basket.count
    }
    
    /// Returns total value of shopping cart items plus shipping cost
    func getBasketTotalPrice() -> Int {
        if let overrideTotal = overrideTotal {
            return overrideTotal
        }
        
        var totalPrice = 0
        if basket.count > 0 {
            let currency = ConsumerViewModel.shared.getCurrency()
            for product in basket {
                if let price = product.price[currency] {
                    totalPrice = totalPrice + price
                }
            }
            totalPrice = totalPrice + getShippingCost()
        }
        return totalPrice
    }
    
    /// Returns the specific Product at certain index position (tableView index)
    func getBasketProduct(_ index: Int) -> Product {
        return basket[index]
    }
    
    /// Returns shipping cost for specific `Currency`
    func getShippingCost() -> Int {
        return shippingCost[ConsumerViewModel.shared.getCurrency()] ?? 0
    }
    
    /// Returns true if shopping basket contains specific `Product`
    func checkIfBasketContains(_ product: Product) -> Bool {
        return basket.contains(where: { $0.id == product.id })
    }
    
    /// Adds the `Product` into shopping basket
    func addToBasket(_ product: Product) {
        basket.append(product)
    }
    
    /// Removes the specific `Product` from shopping basket
    func removeFromBasket(_ product: Product) {
        basket.removeAll(where: { $0.id == product.id })
    }
    
    /// Removes all items from shopping basket
    func clearBasket() {
        basket = []
        overrideTotal = nil
    }
    
    /// Returns `PurchaseItem` array to be sent to the backend in merchantData
    func getPurchaseItems() -> [PurchaseItem] {
        var items: [PurchaseItem] = []
        if basket.count > 0 {
            for product in basket {
                if !items.contains(where: { $0.itemId == product.id } ) {
                    if let price = product.price[ConsumerViewModel.shared.getCurrency()] {
                        let item = PurchaseItem.init(itemId: product.id, itemName: product.name, quantity: 1, price: price, vat: product.vat)
                        items.append(item)
                    }
                }
            }
            items.append(PurchaseItem.init(itemId: "shipping", itemName: "shipping", quantity: 1, price: getShippingCost(), vat: 25))
            
            if let overrideTotal = overrideTotal {
                for i in items.indices {
                    items[i].price = 0
                }
                items[0].price = overrideTotal
            }
        }
        
        return items
    }
}
