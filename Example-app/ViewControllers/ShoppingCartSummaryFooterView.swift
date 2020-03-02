import UIKit

class ShoppingCartSummaryFooterCell: UITableViewCell {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        return formatter
    }()
    
    @IBOutlet private weak var shippingPriceLabel: UILabel!
    @IBOutlet private weak var totalPriceLabel: UILabel!
    
    var checkoutCallback: (() -> Void)?
    var onChangeTotalPressed: (() -> Void)?
    
    /// Checkout button click triggers the payment
    @IBAction func checkoutButtonClick(_ sender: Any) {
        checkoutCallback?()
    }
    
    @IBAction func changeTotalClick(_ sender: Any) {
        onChangeTotalPressed?()
    }
    
    /// Sets the summary values in place
    func setPrices() {
        let currency = ConsumerViewModel.shared.getCurrency()
        shippingPriceLabel.text = "\(StoreViewModel.shared.getShippingCost() / 100) \(currency.rawValue)"
        
        let totalCents = StoreViewModel.shared.getBasketTotalPrice()
        let total = Decimal(totalCents) / Decimal(100)
        let hasFraction = totalCents % 100 != 0
        let formatter = ShoppingCartSummaryFooterCell.currencyFormatter
        formatter.minimumFractionDigits = hasFraction ? 2 : 0
        formatter.maximumFractionDigits = hasFraction ? 2 : 0
        let formattedTotal = formatter.string(from: total as NSDecimalNumber) ?? ""
        totalPriceLabel.text = "\(formattedTotal) \(ConsumerViewModel.shared.getCurrency().rawValue)"
    }
}
