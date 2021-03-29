import UIKit
import SwedbankPaySDK

class ResultViewController: UIViewController {
    
    @IBOutlet private var logView: UITextView!
    @IBOutlet private weak var resultLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let result = PaymentViewModel.shared.result
        
        switch result {
        case .success:
            self.title = "Thank you"
            resultLabel.text = "Payment was successfully completed."
        case .error(let error):
            handleFailure(error: error)
            self.title = "Error"
            resultLabel.text = "There was an error in processing the payment."
        case .unknown:
            resultLabel.text = "Something went wrong."
        }
        
        logView.text = PaymentViewModel.shared.lastPaymentNavigationLogString
    }
    
    @IBAction func copyLogButtonPressed(_ sender: Any) {
        PaymentViewModel.shared.copyPaymentLogToPasteboard()
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "backToStore", sender: self)
    }
    
    private func handleFailure(error: Error) {
        switch error {
        case let error as SwedbankPaySDKController.WebContentError:
            handleWebContentError(error)
        case let error as SwedbankPaySDK.MerchantBackendError:
            handleMerchantBackendError(error)
        default:
            // This should never happen, as SwedbankPaySDKController
            // should only report its own WebContentErrors, or errors
            // from the configuration, which here we know to only
            // report SwedbankPaySDK.MerchantBackendErrors
            print("Unexpected error: \(error)")
        }
    }
    
    private func handleWebContentError(_ error: SwedbankPaySDKController.WebContentError) {
        switch error {
        case .ScriptLoadingFailure(let scriptUrl):
            print("Could not load script at \(scriptUrl?.absoluteString ?? "")")
        case .ScriptError(let terminalFailure):
            print("Fatal error from script: \(terminalFailure.map(String.init(describing:)) ?? "")")
        case .RedirectFailure(let error):
            print("Payment redirect failed: \(error)")
        }
    }
    
    private func handleMerchantBackendError(_ error: SwedbankPaySDK.MerchantBackendError) {
        switch error {
        case .nonWhitelistedDomain(let failingUrl):
            print("Attempt to follow link to non-whitelisted domain: \(failingUrl.absoluteString)")
        case .networkError(let error):
            print("Network error: \(error)")
        case .problem(let problem):
            handleProblem(problem)
        case .missingRequiredOperation(let name):
            print("Protocol error: missing required operation \(name)")
        case .paymentNotInInstrumentMode:
            print("Cannot set instrument of non-instrument mode payment")
        }
    }
    
    // MARK: - Problem handling
    
    /// Prints out all possible reveived `Problem`s
    private func handleProblem(_ problem: SwedbankPaySDK.Problem) {
        switch problem {
        
        /// Client errors (HTTP Status code in range of 400..499)
        case .client(.mobileSDK(.invalidRequest(let message, let raw))):
            printMobileSDKProblem("Client/MobileSDK/InvalidRequest", message: message, raw: raw)
        case .client(.mobileSDK(.unauthorized(let message, let raw))):
            printMobileSDKProblem("Client/MobileSDK/Unauthorized", message: message, raw: raw)
        case .client(.swedbankPay(let type, let title, let status, let detail, let instance, let action, let problems, let raw)):
            switch type {
            case .forbidden:
                printSwedbankPayProblem("Client/SwedbankPay/Forbidden", title: title, status: status, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            case .inputError:
                printSwedbankPayProblem("Client/SwedbankPay/InputError", title: title, status: status, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            case .notFound:
                printSwedbankPayProblem("Client/SwedbankPay/NotFound", title: title, status: status, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            }
        case .client(.unexpectedContent(let status, let contentType, let body)):
            printUnexpectedContentProblem("Client/UnexpectedContent", status: status, contentType: contentType, body: body)
        case .client(.unknown(let type, let title, let status, let detail, let instance, let raw)):
            printUnknownProblem("Client/Unknown", type: type, title: title, status: status, detail: detail, instance: instance, raw: raw)
        
        /// Server errors (HTTP Status code in range of 500...599)
        case .server(.mobileSDK(.backendConnectionFailure(let message, let raw))):
            printMobileSDKProblem("Server/MobileSDK/BackendConnectionFailure", message: message, raw: raw)
        case .server(.mobileSDK(.backendConnectionTimeout(let message, let raw))):
            printMobileSDKProblem("Server/MobileSDK/BackendConnectionTimeout", message: message, raw: raw)
        case .server(.mobileSDK(.invalidBackendResponse(_, _, let body, let raw))):
            printMobileSDKProblem("Server/MobileSDK/InvalidBackendResponse", message: body, raw: raw)
        case .server(.swedbankPay(let type, let title, let status, let detail, let instance, let action, let problems, let raw)):
            switch type {
            case .configurationError:
                printSwedbankPayProblem("Server/SwedbankPay/ConfigurationError", title: title, status: status, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            case .systemError:
                printSwedbankPayProblem("Server/SwedbankPay/SystemError", title: title, status: status, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            }
        case .server(.unexpectedContent(let status, let contentType, let body)):
            printUnexpectedContentProblem("Server/UnexpectedContent", status: status, contentType: contentType, body: body)
        case .server(.unknown(let type, let title, let status, let detail, let instance, let raw)):
            printUnknownProblem("Server/Unknown", type: type, title: title, status: status, detail: detail, instance: instance, raw: raw)
        }
    }
    
    /// Prints out Client or Server MobileSDK `Problem` in a readable format
    private func printMobileSDKProblem(_ errorType: String,
                                       message: String?,
                                       raw: [String: Any])
    {
        print("""
            PROBLEM: \(errorType):
                message: \(message ?? "")
                raw:     \(raw)
            """)
    }
    
    /// Prints out Client or Server SwedbankPay `Problem` in a readable format
    private func printSwedbankPayProblem(_ errorType: String,
                                         title: String?,
                                         status: Int,
                                         detail: String?,
                                         instance: String?,
                                         action: String?,
                                         problems: [SwedbankPaySDK.SwedbankPaySubProblem]?,
                                         raw: [String: Any])
    {
        print("""
            PROBLEM: \(errorType):
                title:    \(title ?? "")
                detail:   \(detail ?? "")
                instance: \(instance ?? "")
                action:   \(action ?? "")
                problems: {\(getSwedbankPaySubProblemStr(problems))}
                raw:      \(raw)
            """)
    }
    
    /// Prints out Client or Server UnexpectedContent `Problem` in a readable format
    private func printUnexpectedContentProblem(_ errorType: String,
                                               status: Int,
                                               contentType: String?,
                                               body: Data?
                                               )
    {
        print("""
            PROBLEM: \(errorType):
                status:      \(status)
                contentType: \(contentType ?? "")
                body:        \(body.flatMap { String(data: $0, encoding: .utf8) } ?? "")
            """)
    }
    
    /// Prints out Client or Server Unknown `Problem` in a readable format
    private func printUnknownProblem(_ errorType: String,
                                     type: String?,
                                     title: String?,
                                     status: Int,
                                     detail: String?,
                                     instance: String?,
                                     raw: [String: Any])
    {
        print("""
            PROBLEM: \(errorType):
                type:     \(type ?? "")
                title:    \(title ?? "")
                status:   \(status)
                detail:   \(detail ?? "")
                instance: \(instance ?? "")
                raw:      \(raw)
            """)
    }
    
    /// Returns Client or Server `SwedbankPaySubProblem` array in a readable format
    private func getSwedbankPaySubProblemStr(_ subProblems: [SwedbankPaySDK.SwedbankPaySubProblem]?) -> String {
        var str = ""
        if let subProblems = subProblems {
            for subProblem in subProblems {
                str.append(contentsOf: """
                
                        {
                            name:        \(subProblem.name ?? "")
                            description: \(subProblem.description ?? "")
                        }
                    
                """)
            }
        }
        
        return str
    }
}
