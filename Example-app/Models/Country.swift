
import SwedbankPaySDK

enum Country {
    case Norway
    case Sweden
    
    var countryCode: String {
        switch self {
        case .Norway:
            return "NO"
        case .Sweden:
            return "SE"
        }
    }
    
    var language: SwedbankPaySDK.Language {
        switch self {
        case .Norway: return .Norwegian
        case .Sweden: return .Swedish
        }
    }
    
    var languageCode: String {
        switch self {
        case .Norway:
            return "no-NO"
        case .Sweden:
            return "sv-SE"
        }
    }
    
    var currency: Currency {
        switch self {
        case .Norway:
            return Currency.NOK
        case .Sweden:
            return Currency.SEK
        }
    }
}
