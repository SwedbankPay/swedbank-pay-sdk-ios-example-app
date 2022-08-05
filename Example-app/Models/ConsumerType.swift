
enum ConsumerType: CaseIterable {
    case Anonymous
    case Checkin
    case Prefill
    
    var displayName: String {
        switch self {
            case .Anonymous:
                return "Anonymous"
            case .Checkin:
                return "Checkin V2"
            case .Prefill:
                return "Prefill"
        }
    }
}
