import UIKit
import SwedbankPaySDK

protocol ConsumerViewModelListener {
    func onCountryChanged()
}

extension Notification.Name {
    /// Notification that is sent when ConsumerViewModel.setCountry is called
    static let ConsumerViewModelCountryChanged = Notification.Name("com.swedbank.ConsumerViewModelCountryChanged")
}

/// Singleton ViewModel for consumer data
class ConsumerViewModel {
    
    static let shared = ConsumerViewModel()
    
    private init() {}
    
    private var consumerType: ConsumerType = .Anonymous
    #if PROD_DEMO
    private var country: Country = .Sweden
    #else
    private var country: Country = .Norway
    #endif
    
    var consumerSettingsOpen = false
    
    var prefillEmail = ""
    var prefillMsisdn = ""
    var prefillProfileRef = ""
    
    /// Returns `Country` currently in use
    func getCountry() -> Country {
        return country
    }
    
    /// Returns `Currency` currently in use
    func getCurrency() -> Currency {
        return country.currency
    }
    
    /// Returns `ConsumerType`, anonymous or identified
    func getConsumerType() -> ConsumerType {
        return consumerType
    }
    
    /// Returns the language code for merchantData
    func getLanguageCode() -> String {
        return country.languageCode
    }
    
    /// Sets `Country` for `Consumer`
    func setCountry(_ country: Country) {
        self.country = country
        NotificationCenter.default.post(name: .ConsumerViewModelCountryChanged, object: self)
    }
    
    /// Sets `ConsumerType`, anonymous or identified
    func setConsumerType(_ type: ConsumerType) {
        self.consumerType = type
    }
    
    /// Returns `Consumer`, nil for anonymous payment
    ///
    /// Test consumers are from [https://developer.payex.com/xwiki/wiki/developer/view/Main/ecommerce/resources/test-data/]
    func getConsumer() -> SwedbankPaySDK.Consumer? {
        if consumerType == .Checkin {
            return SwedbankPaySDK.Consumer(
                language: country.language,
                shippingAddressRestrictedToCountryCodes: [country.countryCode]
            )
        } else {
            return nil
        }
    }
    
    func checkinV3() -> Bool {
        false
        //we do PaymentsOnly for now
    }
    
    func getPaymentOrderPayer() -> SwedbankPaySDK.PaymentOrderPayer? {
        if consumerType == .Prefill {
            return SwedbankPaySDK.PaymentOrderPayer(
                consumerProfileRef: prefillProfileRef.nonEmptyOrNil,
                email: prefillEmail.nonEmptyOrNil,
                msisdn: prefillMsisdn.nonEmptyOrNil
            )
        } else if checkinV3() {
            return SwedbankPaySDK.PaymentOrderPayer(requireConsumerInfo: true, digitalProducts: false, shippingAddressRestrictedToCountryCodes: [country.countryCode])
        }
        else {
            return nil
        }
    }
}

private extension String {
    var nonEmptyOrNil: String? {
        return isEmpty ? nil : self
    }
}
