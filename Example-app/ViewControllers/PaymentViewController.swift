import UIKit
import SwedbankPaySDK

class PaymentViewController: UIViewController {
    
    /// UIView to instantiate the SwedbankPaySDKController into; SwedbankPaySDKController will instantiate WKWebView
    @IBOutlet private weak var webViewContainer: UIView!
    
    private var paymentLog: [URL] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Payment"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.alpha = 1

        let vm = PaymentViewModel.shared
        let swedbankPaySDKController = SwedbankPaySDKController.init(
            configuration: vm.configuration,
            consumer: vm.consumerData,
            paymentOrder: vm.paymentOrder
        )
        vm.lastPaymentNavigationLog = []
        swedbankPaySDKController.webNavigationLogger = {
            PaymentViewModel.shared.lastPaymentNavigationLog?.append($0)
        }
        if vm.useSafari {
            swedbankPaySDKController.webRedirectBehavior = .AlwaysUseBrowser
        } else if vm.ignoreGoodRedirectsList {
            swedbankPaySDKController.webRedirectBehavior = .AlwaysUseWebView
        } else {
            swedbankPaySDKController.webRedirectBehavior = .Default
        }
        swedbankPaySDKController.delegate = self
        addChild(swedbankPaySDKController)
        webViewContainer.addSubview(swedbankPaySDKController.view)
        swedbankPaySDKController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            swedbankPaySDKController.view.topAnchor.constraint(equalTo: webViewContainer.topAnchor),
            swedbankPaySDKController.view.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor),
            swedbankPaySDKController.view.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor),
            swedbankPaySDKController.view.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor),
        ])
        
        swedbankPaySDKController.didMove(toParent: self)
    }
}

/// Need to conform to SwedbankPaySDKDelegate protocol
extension PaymentViewController: SwedbankPaySDKDelegate {
    
    func paymentComplete() {
        PaymentViewModel.shared.setResult(.success)
        performSegue(withIdentifier: "showResult", sender: self)
    }
    
    func paymentFailed(failureReason: SwedbankPaySDKController.FailureReason) {
        PaymentViewModel.shared.setResult(.error(failureReason))
        performSegue(withIdentifier: "showResult", sender: self)
    }
    
    func paymentCanceled() {
        PaymentViewModel.shared.setResult(.unknown)
        performSegue(withIdentifier: "backToStore", sender: self)
    }
}
