import CoreServices
import UIKit
import SwedbankPaySDK
import SwedbankPaySDKMerchantBackend

/// Singleton ViewModel for payment data
class PaymentViewModel {
    static let InstrumentPickerOpenChangedNotification = Notification.Name(
        "com.swedbank.InstrumentPickerOpenChanged"
    )
    static let InstrumentChangedNotification = Notification.Name(
        "com.swedbank.InstrumentChanged"
    )
    static let PaymentTokenChangedNotification = Notification.Name(
        "com.swedbank.PaymentTokenChanged"
    )
    
    enum Environment: CaseIterable {
        case Stage
        case ExternalIntegration
        case PaymentPagesExternalIntegration
        case EnterpriseExternalIntegration
        case BadRedirectDemo
        #if PROD_DEMO
        case Prod
        #endif
    }
    
    enum InstrumentOption: Hashable {
        case disabled
        case instrument(SwedbankPaySDK.Instrument)
        case custom
        
        var name: String {
            switch self {
            case .disabled: return "Disabled"
            case .instrument(let instrument): return instrument.rawValue
            case .custom: return "Custom"
            }
        }
    }
    
    static let shared = PaymentViewModel()
    
    private init() {}
    
    /// URL for the Swedbank Pay SDK to connect to
    private var backendUrl: URL {
        switch environment {
        case .Stage:
            return URL(string: "https://stage-dot-payex-merchant-samples.ey.r.appspot.com/")!
        case .ExternalIntegration:
            return URL(string: "https://payex-merchant-samples.ey.r.appspot.com/")!
        case .PaymentPagesExternalIntegration:
            return URL(string: "https://pp-dot-payex-merchant-samples.ey.r.appspot.com/")!
        case .EnterpriseExternalIntegration:
            return URL(string: "https://enterprise-dev-dot-payex-merchant-samples.ey.r.appspot.com/")!
        case .BadRedirectDemo:
            return URL(string: "https://us-central1-qvik-swedbankpay-badredirect.cloudfunctions.net/api/")!
        #if PROD_DEMO
        case .Prod:
            return URL(string: "https://payex-merchant-samples-prod.appspot.com")!
        #endif
        }
    }
    
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
    
    var lastPaymentNavigationLog: [URL] = []
    
    var lastPaymentNavigationLogString: String? {
        let log = lastPaymentNavigationLog
        if !log.isEmpty {
            var hosts = Set<String>()
            var logString = ""
            for host in log.lazy.compactMap({ $0.host }) {
                let (inserted, _) = hosts.insert(host)
                if inserted {
                    logString += host
                    logString += "\n"
                }
            }
            return logString
        } else {
            return nil
        }
    }
    
    var errorLog: [String] = []
    
    // Default environment
    var environment = Environment.Stage
    
    var settingsOpen = false
    
    let instrumentOptions: [InstrumentOption] = [
        .disabled,
        .instrument(.creditCard),
        .instrument(.swish),
        .instrument(.vipps),
        .instrument(.invoiceSE),
        .instrument(.invoiceNO),
        .instrument(.monthlyInvoiceSE),
        .instrument(.carPay),
        .instrument(.creditAccount),
        .custom
    ]
    var instrumentPickerOpen = false {
        didSet {
            NotificationCenter.default.post(
                name: PaymentViewModel.InstrumentPickerOpenChangedNotification,
                object: self
            )
        }
    }
    var instrumentOptionIndex = 0 {
        didSet {
            NotificationCenter.default.post(name: PaymentViewModel.InstrumentChangedNotification, object: self)
        }
    }
    var instrumentOption: InstrumentOption {
        instrumentOptions[instrumentOptionIndex]
    }
    var customInstrument: String? {
        didSet {
            NotificationCenter.default.post(name: PaymentViewModel.InstrumentChangedNotification, object: self)
        }
    }
    
    var disablePaymentMenu = false
    var ignoreGoodRedirectsList = false
    var useSafari = false
    var testWrongHostUrl = false
    
    var restrictedToInstruments: [String]?
    
    var payerReference: String?
    var paymentToken: String? {
        didSet {
            NotificationCenter.default.post(name: PaymentViewModel.PaymentTokenChangedNotification, object: self)
        }
    }
    var generatePaymentToken = false
    
    var subsite: String?
    
    var styleOpen = false
    var styleText = ""
    var trimmedStyleText: String {
        styleText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var style: [String: Any]? {
        let trimmed = trimmedStyleText
        let empty = trimmed.isEmpty
        return empty ? nil : StyleParser.parse(text: trimmed)
    }
    
    /// Configuration for SwedbankPaySDK
    var configuration: SwedbankPaySDK.MerchantBackendConfiguration {
        get {
            return SwedbankPaySDK.MerchantBackendConfiguration.init(
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
    
    func checkinV3() -> Bool {
        ConsumerViewModel.shared.checkinV3()
    }
    
    var instrument: SwedbankPaySDK.Instrument? {
        get {
            switch instrumentOption {
            case .disabled: return nil
            case .instrument(let instrument): return instrument
            case .custom:
                let instrument = customInstrument ?? ""
                return instrument.isEmpty ? nil : .init(rawValue: instrument)
            }
        }
    }
    
    private var payer: SwedbankPaySDK.PaymentOrderPayer? {
        get {
            if let payerReference = payerReference {
                return .init(msisdn: nil, payerReference: payerReference)
            } else {
                return ConsumerViewModel.shared.getPaymentOrderPayer()
            }
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
            
            let payeeInfo = SwedbankPaySDK.PayeeInfo.init(
                subsite: subsite
            )
            
            return SwedbankPaySDK.PaymentOrder.init(
                currency: country.currency.rawValue,
                amount: amount,
                vatAmount: vatAmount,
                description: "Purchase",
                language: country.language,
                instrument: instrument,
                generatePaymentToken: generatePaymentToken,
                restrictedToInstruments: restrictedToInstruments,
                urls: buildUrls(),
                payeeInfo: payeeInfo,
                payer: payer,
                orderItems: orderItems,
                disablePaymentMenu: disablePaymentMenu,
                paymentToken: paymentToken
            )
        }
    }
    
    private func buildUrls() -> SwedbankPaySDK.PaymentOrderUrls {
        let language = ConsumerViewModel.shared.getCountry().language
        if testWrongHostUrl {
            let hostUrl = URL(string: "https://bogus-hosturl-for-testing.swedbankpay.com/")!
            return .init(configuration: configuration, language: language, hostUrl: hostUrl)
        } else {
            return .init(configuration: configuration, language: language)
        }
    }
    
    /// Result handling
    private(set) var result: PaymentResult = .unknown
    
    /// Sets the result of the payment, and if the payment was successful, empties the shopping basket
    func setResult(_ result: PaymentResult) {
        if case .success = result {
            StoreViewModel.shared.clearBasket()
        }
        self.result = result
    }
    
    func copyPaymentLogToPasteboard() {
        if let log = lastPaymentNavigationLogString {
            UIPasteboard.general.setValue(log, forPasteboardType: kUTTypeUTF8PlainText as String)
        }
    }
    
    func setPayerReferenceToLastUsed() {
        payerReference = getLastUsedPayerReference()
    }
    func getLastUsedPayerReference() -> String? {
        return UserDefaults.standard.string(forKey: "LastUsedPayerReference")
    }
    func saveLastUsedPayerReference(payerReference: String) {
        UserDefaults.standard.setValue(payerReference, forKey: "LastUsedPayerReference")
    }
}
