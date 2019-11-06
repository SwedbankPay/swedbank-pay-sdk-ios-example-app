import UIKit
import SwedbankPaySDK

/// Singleton ViewModel for consumer data
class ConsumerViewModel {
    
    static let shared = ConsumerViewModel()
    
    private init() {}
    
    /// In this example the default `Consumer` is unidentified Norwegian
    private var consumerType: ConsumerType = .Anonymous
    private var country: Country = .Norway
    private var currency: Currency = .NOK
    
    /// Returns `Country` currently in use
    public func getCountry() -> Country {
        return country
    }
    
    /// Returns `Currency` currently in use
    public func getCurrency() -> Currency {
        return currency
    }
    
    /// Returns `ConsumerType`, anonymous or identified
    public func getConsumerType() -> ConsumerType {
        return consumerType
    }
    
    /// Returns the language code for merchantData
    public func getLanguageCode() -> String {
        switch country {
        case .Norway:
            return "no-NO"
        case .Sweden:
            return "sv-SE"
        }
    }
    
    /// Sets `Country` for `Consumer`
    public func setCountry(_ country: Country) {
        self.country = country
        switch country {
        case .Norway:
            self.currency = .NOK
        case .Sweden:
            self.currency = .SEK
        }
    }
    
    /// Sets `ConsumerType`, anonymous or identified
    public func setConsumerType(_ type: ConsumerType) {
        self.consumerType = type
    }
    
    /// Returns `Consumer`, nil for anonymous payment
    ///
    /// Test consumers are from [https://developer.payex.com/xwiki/wiki/developer/view/Main/ecommerce/resources/test-data/]
    public func getConsumer() -> SwedbankPaySDK.Consumer? {
        switch consumerType {
        case .Anonymous:
            return nil
        case .Identified:
            switch country {
            case .Norway:
                return SwedbankPaySDK.Consumer.init(
                    consumerCountryCode: "NO",
                    msisdn: "+4798765432",
                    email: "olivia.nyhuus@payex.com",
                    nationalIdentifier: SwedbankPaySDK.NationalIdentifier.init(
                        socialSecurityNumber: "26026708248",
                        countryCode: "NO"
                    )
                )
            case .Sweden:
                return SwedbankPaySDK.Consumer.init(
                    consumerCountryCode: "SE",
                    msisdn: "+46739000001",
                    email: "leia.ahlstrom@payex.com",
                    nationalIdentifier: SwedbankPaySDK.NationalIdentifier.init(
                        socialSecurityNumber: "971020-2392",
                        countryCode: "SE"
                    )
                )
            }
        }
    }
}
