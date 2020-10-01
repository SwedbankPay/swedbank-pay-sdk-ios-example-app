
import SwedbankPaySDK

enum PaymentResult {
    case unknown
    case error(Error)
    case success
}
