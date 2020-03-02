import UIKit

class ShoppingCartProductTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var productImage: UIImageView!
    @IBOutlet private weak var productNameLabel: UILabel!
    @IBOutlet private weak var productPriceLabel: UILabel!
    @IBOutlet private weak var productHighlight: UIView!
    
    private var product: Product?
    
    var basketChangedCallback: (()->())?
    
    /// Removes the `Product` from shopping basket
    @IBAction func removeFromBasketButtonClick(_ sender: Any) {
        if let product = product {
            StoreViewModel.shared.removeFromBasket(product)
            self.basketChangedCallback?()
        }
    }
    
    /// Sets the `Product` information in place
    func setProductDetails(_ product: Product?) {
        if let product = product {
            
            self.product = product
            
            productImage.image = UIImage.init(imageLiteralResourceName: product.image)
            
            productNameLabel.text = product.name
            
            let currency = ConsumerViewModel.shared.getCurrency()
            let price = String((product.price[currency] ?? 0) / 100)
            
            productPriceLabel.text = "\(price) \(currency.rawValue)"
            
            productHighlight.backgroundColor = UIColor(rgb: product.highlightHexColor)
        }
    }
}
