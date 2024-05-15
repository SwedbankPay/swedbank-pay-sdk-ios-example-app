enum ScanUrl: String {
    case checkout
    case base
    case complete
    case cancel
    case payment
    case sessionApi
    case swish
    case unknown
    
    func toKey() -> StorageHelper.Key? {
            switch self {
            case .base:
                return .baseUrl
            case .complete:
                return .completeUrl
            case .cancel:
                return .cancelUrl
            case .payment:
                return .paymentUrl
            default:
                return nil
            }
        }
}
