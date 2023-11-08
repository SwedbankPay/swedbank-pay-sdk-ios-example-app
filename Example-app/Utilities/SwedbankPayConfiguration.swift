import Foundation
import SwedbankPaySDK

enum SwedbankPayConfigurationError: Error {
  case notImplemented
}

class SwedbankPayConfiguration {
    let orderInfo: SwedbankPaySDK.ViewPaymentOrderInfo
    
    init(isV3: Bool = true, webViewBaseURL: URL?,
         viewPaymentLink: URL, completeUrl: URL, cancelUrl: URL?,
         paymentUrl: URL? = nil, termsOfServiceUrl: URL? = nil) {
        self.orderInfo = SwedbankPaySDK.ViewPaymentOrderInfo(
            isV3: isV3,
            webViewBaseURL: webViewBaseURL,
            viewPaymentLink: viewPaymentLink,
            completeUrl: completeUrl,
            cancelUrl: cancelUrl,
            paymentUrl: paymentUrl,
            termsOfServiceUrl: termsOfServiceUrl
        )
    }
}

extension SwedbankPayConfiguration: SwedbankPaySDKConfiguration {
    
    // This delegate method is not used but required
    func postConsumers(consumer: SwedbankPaySDK.Consumer?, userData: Any?, completion: @escaping (Result<SwedbankPaySDK.ViewConsumerIdentificationInfo, Error>) -> Void) {
        completion(.failure(SwedbankPayConfigurationError.notImplemented))
    }
    
    func postPaymentorders(paymentOrder: SwedbankPaySDK.PaymentOrder?, userData: Any?, consumerProfileRef: String?, options: SwedbankPaySDK.VersionOptions, completion: @escaping (Result<SwedbankPaySDK.ViewPaymentOrderInfo, Error>) -> Void) {
        completion(.success(orderInfo))
    }
}
