
import SwedbankPaySDK

enum PaymentResult {
    case unknown
    case error(SwedbankPaySDKController.FailureReason)
    case success
}
