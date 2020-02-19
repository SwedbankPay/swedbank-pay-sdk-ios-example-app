import UIKit
import SwedbankPaySDK

/// Singleton ViewModel for consumer data
class ConsumerViewModel {
    
    static let shared = ConsumerViewModel()
    
    private init() {}
    
    /// In this example the default `Consumer` is unidentified Norwegian
    private var consumerType: ConsumerType = .Anonymous
    private var country: Country = .Norway
    
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
    }
    
    /// Sets `ConsumerType`, anonymous or identified
    func setConsumerType(_ type: ConsumerType) {
        self.consumerType = type
    }
    
    /// Returns `Consumer`, nil for anonymous payment
    ///
    /// Test consumers are from [https://developer.payex.com/xwiki/wiki/developer/view/Main/ecommerce/resources/test-data/]
    func getConsumer() -> SwedbankPaySDK.Consumer? {
        switch consumerType {
        case .Anonymous:
            return nil
        case .Identified:
            switch country {
            case .Norway:
                return SwedbankPaySDK.Consumer.init(
                    language: .Norwegian,
                    shippingAddressRestrictedToCountryCodes: ["NO"]
                )
            case .Sweden:
                return SwedbankPaySDK.Consumer.init(
                    language: .Swedish,
                    shippingAddressRestrictedToCountryCodes: ["SE"]
                )
            }
        }
    }
}
