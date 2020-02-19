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
            var amount: Int64 = 0
            var vatAmout: Int64 = 0
            for item in StoreViewModel.shared.getPurchaseItems() {
                amount += Int64(item.price)
                vatAmout += Int64(item.price * item.vat / 100)
            }
            
            return SwedbankPaySDK.PaymentOrder.init(
                currency: ConsumerViewModel.shared.getCurrency().rawValue,
                amount: amount,
                vatAmount: vatAmout,
                description: "Purchase",
                urls: .init(configuration: configuration)
            )
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
