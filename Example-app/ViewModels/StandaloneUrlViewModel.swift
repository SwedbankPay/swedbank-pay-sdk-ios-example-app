import Foundation
import SwedbankPaySDK

extension StandaloneUrlView {
    class StandaloneUrlViewModel: ObservableObject, SwedbankPaySDKDelegate {
        @Published var viewCheckoutUrl: String = ""
        @Published var baseUrl: String
        @Published var completeUrl: String
        @Published var cancelUrl: String
        @Published var sessionApiUrl: String = ""
        @Published var swishNumber: String = ""
        @Published var useCheckoutV3: Bool
        
        @Published var paymentUrlAuthorityAndPath: String
        @Published var paymentUrlScheme: String
        
        @Published var displaySwedbankPayController: Bool = false
        @Published var displayScannerSheet: Bool = false
        
        @Published var showingAlert = false
        @Published var error: Error?
        @Published var retry: (()->Void)?
        
        @Published var paymentResultIcon: String?
        @Published var paymentResultMessage: String?
        
        @Published var availableInstrument: [SwedbankPaySDK.AvailableInstrument]?
        
        init() {
            baseUrl = String(StorageHelper.shared.value(for: .baseUrl) ?? "")
            completeUrl = String(StorageHelper.shared.value(for: .completeUrl) ?? "")
            cancelUrl = String(StorageHelper.shared.value(for: .cancelUrl) ?? "")
            useCheckoutV3 = Bool(StorageHelper.shared.value(for: .useCheckoutV3) ?? true)
            paymentUrlAuthorityAndPath = String(StorageHelper.shared.value(for: .paymentUrl) ?? "")
            paymentUrlScheme = "stand_alone_url_payment_payment_url_scheme".localize
        }
        
        var isCheckoutEnabled: Bool {
            return !viewCheckoutUrl.isEmpty && !completeUrl.isEmpty
        }
        
        func configurePayment() -> SwedbankPayConfiguration? {
            guard let completeUrl = URL(string: completeUrl) else {
                return nil
            }
            
            var viewPaymentLink: URL
            if let url = URL(string: viewCheckoutUrl) {
                viewPaymentLink = url
            } else {
                viewPaymentLink = URL(string: "https://")!
            }
            
            StorageHelper.shared.save(value: baseUrl, forKey: .baseUrl)
            StorageHelper.shared.save(value: self.completeUrl, forKey: .completeUrl)
            StorageHelper.shared.save(value: cancelUrl, forKey: .cancelUrl)
            StorageHelper.shared.save(value: useCheckoutV3, forKey: .useCheckoutV3)
            StorageHelper.shared.save(value: paymentUrlAuthorityAndPath, forKey: .paymentUrl)
            
            let paymentUrl = paymentUrlScheme+paymentUrlAuthorityAndPath
            
            let configuration = SwedbankPayConfiguration(
                isV3: useCheckoutV3,
                webViewBaseURL: URL(string: baseUrl),
                viewPaymentLink: viewPaymentLink,
                completeUrl: completeUrl,
                cancelUrl: URL(string: cancelUrl),
                paymentUrl: URL(string: paymentUrl)
            )
            
            return configuration
        }
        
        func saveUrl(urlType: ScanUrl, url: String) {
            if let key = urlType.toKey() {
                StorageHelper.shared.save(value: url, forKey: key)
            }
        }
        
        private func setPaymentResult(success: Bool, resultText: String) {
            paymentResultIcon = success ? "payment_success_icon" : "payment_failed_icon"
            
            paymentResultMessage = resultText
            
            displaySwedbankPayController = false
        }
        
        func paymentComplete() {
            setPaymentResult(success: true, resultText: "stand_alone_url_payment_successful".localize)
        }
        
        func paymentFailed(error: Error) {
            setPaymentResult(success: false, resultText: error.localizedDescription)
        }
        
        func sessionProblemOccurred(problem: SwedbankPaySDK.ProblemDetails) {
            setPaymentResult(success: false, resultText: problem.detail ?? "")
        }
        
        func sdkProblemOccurred(problem: SwedbankPaySDK.NativePaymentProblem) {
            switch problem {
            case .clientAppLaunchFailed:
                setPaymentResult(success: false, resultText: "stand_alone_client_app_launch_failed".localize)
            case .paymentSessionAPIRequestFailed(let error, let retry):
                self.error = error
                self.retry = retry
                self.showingAlert = true
            case .paymentSessionEndStateReached:
                setPaymentResult(success: false, resultText: "stand_alone_url_payment_session_end_state_reached".localize)
            case .internalInconsistencyError:
                setPaymentResult(success: false, resultText: "stand_alone_internal_inconsistency_error".localize)
            }
        }
        
        func paymentCanceled() {
            setPaymentResult(success: false, resultText: "stand_alone_url_payment_cancelled".localize)
        }
        
        func availableInstrumentsFetched(_ availableInstruments: [SwedbankPaySDK.AvailableInstrument]) {
            self.availableInstrument = availableInstruments
        }
    }
}
