import SwedbankPaySDK

/// Singleton ViewModel for payment data
class PaymentViewModel {
    
    static let shared = PaymentViewModel()
    
    private init() {}
    
    /// URL for the Swedbank Pay SDK to connect to
    private let backendUrl = URL(string: "https://payex-merchant-samples.appspot.com")!
    
    /// Creates api request header names and values dictionary; define these in the backend receiving the requests from the app
    private let headers: Dictionary<String, String> = [
        "x-payex-sample-apikey": "c339f53d-8a36-4ea9-9695-75048e592cc0",
        "x-payex-sample-access-token": NSUUID().uuidString.lowercased()
    ]
    
    /// List of allowed domains.
    ///
    /// By default, the domain of the backend URL is whitelisted, including its subdomains. If you wish to change that default,
    /// you must add all domains, including backend URL; in that situation it is not included by default.
    private let domainWhitelist: [SwedbankPaySDK.WhitelistedDomain]? = nil
    
    /// List of certificates to pin
    ///
    /// If empty, certificate pinning is not implemented
    private let pinPublicKeys: [SwedbankPaySDK.PinPublicKeys]? = nil
    
    var settingsOpen = false
    
    var disablePaymentMenu = false
    var useSafari = false
    var testWrongHostUrl = false
    
    var restrictedToInstruments: [String]?
    
    /// Configuration for SwedbankPaySDK
    var configuration: SwedbankPaySDK.Configuration {
        get {
            return SwedbankPaySDK.Configuration.init(
                backendUrl: self.backendUrl,
                headers: self.headers,
                domainWhitelist: self.domainWhitelist,
                pinPublicKeys: self.pinPublicKeys
            )
        }
    }
    
    /// If consumerData is nil, payment is anonymous
    var consumerData: SwedbankPaySDK.Consumer? {
        get {
            ConsumerViewModel.shared.getConsumer()
        }
    }
    
    /// Sample Payment Order
    var paymentOrder: SwedbankPaySDK.PaymentOrder {
        get {
            let orderItems: [SwedbankPaySDK.OrderItem] = StoreViewModel.shared.getPurchaseItems().map { item in
                let isShipping = item.itemId == "shipping"
                return SwedbankPaySDK.OrderItem(
                    reference: item.itemId,
                    name: item.itemName,
                    type: isShipping ? .ShippingFee : .Product,
                    class: isShipping ? "Shipping" : "Shoe",
                    quantity: 1,
                    quantityUnit: isShipping ? "pc" : "pair",
                    unitPrice: Int64(item.price),
                    vatPercent: 2500,
                    amount: Int64(item.price),
                    vatAmount: Int64(item.price / 5)
                )
            }
            let amount = orderItems.lazy.map { $0.amount }.reduce(0, +)
            let vatAmount = orderItems.lazy.map { $0.vatAmount }.reduce(0, +)
            
            let country = ConsumerViewModel.shared.getCountry()
                        
            return SwedbankPaySDK.PaymentOrder.init(
                currency: country.currency.rawValue,
                amount: amount,
                vatAmount: vatAmount,
                description: "Purchase",
                language: country.language,
                restrictedToInstruments: restrictedToInstruments,
                urls: buildUrls(),
                orderItems: orderItems,
                disablePaymentMenu: disablePaymentMenu
            )
        }
    }
    
    private func buildUrls() -> SwedbankPaySDK.PaymentOrderUrls {
        if testWrongHostUrl {
            let hostUrl = URL(string: "https://bogus-hosturl-for-testing.swedbankpay.com/")!
            return .init(configuration: configuration, hostUrl: hostUrl)
        } else {
            return .init(configuration: configuration)
        }
    }
    
    /// Result handling
    private(set) var result: PaymentResult = .unknown
    private(set) var problem: SwedbankPaySDK.Problem?
    
    /// Sets the result of the payment, and if the payment was successful, empties the shopping basket
    func setResult(_ result: PaymentResult, problem: SwedbankPaySDK.Problem? = nil) {
        if result == .success {
            StoreViewModel.shared.clearBasket()
        }
        self.result = result
        self.problem = problem
    }
}
