import Foundation
import SwiftUI
import SwedbankPaySDK
import UIKit

extension StandaloneUrlView {
    class StandaloneUrlViewModel: ObservableObject, SwedbankPaySDKDelegate, SwedbankPaySDKPaymentSessionDelegate {
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
        @Published var isLoadingNativePayment: Bool = false

        @Published var displayPaymentSessionSwedbankPayController: Bool = false
        @Published var paymentSessionSwedbankPayController: SwedbankPaySDKController?
        
        @Published var showingAlert = false
        @Published var errorTitle: String?
        @Published var errorMessage: String?
        @Published var retry: (()->Void)?
        
        @Published var paymentResultIcon: String?
        @Published var paymentResultMessage: String?
        
        @Published var nativePayment: SwedbankPaySDK.SwedbankPayPaymentSession?
        @Published var availableInstruments: [SwedbankPaySDK.AvailableInstrument]?

        @Published var show3DSecureViewController = false
        @Published var paymentSession3DSecureViewController: UIViewController?

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
            displayPaymentSessionSwedbankPayController = false
            isLoadingNativePayment = false
            
            viewCheckoutUrl = ""
            sessionApiUrl = ""
            swishNumber = ""
            
            nativePayment = nil
            availableInstruments = nil
        }
        
        private func showAlert(error: Error, retry: (()->Void)? = nil) {
            showAlert(errorTitle: nil,
                      errorMessage: "\((error as NSError).code): \(error.localizedDescription)\n\n\((error as NSError).domain)",
                      retry: retry)
        }
        
        private func showAlert(errorTitle: String?, errorMessage: String?, retry: (()->Void)? = nil) {
            self.errorTitle = errorTitle
            self.errorMessage = errorMessage
            self.retry = retry
            self.showingAlert = true
            
            isLoadingNativePayment = false
        }

        private func showAlertOnPaymentSession3DSecureViewController(error: Error, retry: (()->Void)?) {
            let alert = UIAlertController(title: nil,
                                          message: "\((error as NSError).code): \(error.localizedDescription)\n\n\((error as NSError).domain)",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "general_ok".localize, style: .cancel, handler: { _ in
                self.show3DSecureViewController = false
                self.paymentSession3DSecureViewController = nil
            }))

            if let retry = retry {
                alert.addAction(UIAlertAction(title: "general_retry".localize, style: .default, handler: { _ in
                    retry()
                }))
            }

            self.paymentSession3DSecureViewController?.present(alert, animated: true, completion: nil)
        }

        func paymentComplete() {
            setPaymentResult(success: true, resultText: "stand_alone_url_payment_successful".localize)
        }

        func paymentCanceled() {
            setPaymentResult(success: false, resultText: "stand_alone_url_payment_cancelled".localize)
        }

        func paymentFailed(error: Error) {
            setPaymentResult(success: false, resultText: error.localizedDescription)
        }

        func paymentSessionComplete() {
            setPaymentResult(success: true, resultText: "stand_alone_url_payment_successful".localize)
        }

        func sessionProblemOccurred(problem: SwedbankPaySDK.ProblemDetails) {
            var errorMessages: [String] = []
            
            if let status = problem.status {
                errorMessages.append(String(status))
            }
            
            if let detail = problem.detail {
                errorMessages.append(detail)
            }
            
            showAlert(errorTitle: problem.title,
                      errorMessage: "\(errorMessages.joined(separator: ": "))\n\n\(problem.type)")
        }
        
        func sdkProblemOccurred(problem: SwedbankPaySDK.PaymentSessionProblem) {
            switch problem {
            case .clientAppLaunchFailed:
                showAlert(errorTitle: nil,
                          errorMessage: "stand_alone_client_app_launch_failed".localize)
            case .paymentSessionAPIRequestFailed(let error, let retry):
                showAlert(error: error, retry: retry)
            case .paymentControllerPaymentFailed(error: let error, retry: let retry):
                showAlert(error: error, retry: retry)
            case .paymentSession3DSecureViewControllerLoadFailed(error: let error, retry: let retry):
                showAlertOnPaymentSession3DSecureViewController(error: error, retry: retry)
            case .paymentSessionEndStateReached:
                setPaymentResult(success: false, resultText: "stand_alone_url_payment_session_end_state_reached".localize)
            case .internalInconsistencyError:
                setPaymentResult(success: false, resultText: "stand_alone_internal_inconsistency_error".localize)
            case .automaticConfigurationFailed:
                setPaymentResult(success: false, resultText: "stand_alone_automatic_configuration_failed".localize)
            }
        }
        
        func paymentSessionCanceled() {
            setPaymentResult(success: false, resultText: "stand_alone_url_payment_cancelled".localize)
        }
        
        func paymentSessionFetched(availableInstruments: [SwedbankPaySDK.AvailableInstrument]) {
            self.availableInstruments = availableInstruments
            isLoadingNativePayment = false
        }

        func show3DSecureViewController(viewController: UIViewController) {
            self.paymentSession3DSecureViewController = viewController
            self.show3DSecureViewController = true
        }

        func dismiss3DSecureViewController() {
            self.show3DSecureViewController = false
            self.paymentSession3DSecureViewController = nil
        }

        func showSwedbankPaySDKController(viewController: SwedbankPaySDKController) {
            paymentSessionSwedbankPayController = viewController
            paymentSessionSwedbankPayController?.delegate = self
            displayPaymentSessionSwedbankPayController = true
            isLoadingNativePayment = false
        }
    }
}

struct SomeView: UIViewControllerRepresentable {
    var viewController: UIViewController

    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        //update Content
    }
}
