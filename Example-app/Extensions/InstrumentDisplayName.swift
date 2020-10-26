import SwedbankPaySDK

extension SwedbankPaySDK.Instrument {
    var displayName: String {
        switch self {
        case .creditCard: return "Card"
        case .swish: return "Swish"
        case .invoice: return "Invoice"
        default: return rawValue
        }
    }
}
