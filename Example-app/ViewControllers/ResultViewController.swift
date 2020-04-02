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
        case .error(let reason):
            handleFailure(failureReason: reason)
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
    
    private func handleFailure(failureReason: SwedbankPaySDKController.FailureReason) {
        switch failureReason {
        case .NetworkError(let error):
            print("Network error: \(error)")
        case .Problem(let problem):
            handleProblem(problem)
        case .ScriptLoadingFailure(let scriptUrl):
            print("Could not load script at \(scriptUrl?.absoluteString ?? "")")
        case .ScriptError(let terminalFailure):
            print("Fatal error from script: \(terminalFailure.map(String.init(describing:)) ?? "")")
        case .NonWhitelistedDomain(let failingUrl):
            print("Attempt to follow link to non-whitelisted domain: \(failingUrl?.absoluteString ?? "")")
        case .MissingField(let name):
            print("Protocol error: missing required field \(name)")
        case .MissingOperation(let name):
            print("Protocol error: missing required operation \(name)")
        }
    }
    
    // MARK: - Problem handling
    
    /// Prints out all possible reveived `Problem`s
    private func handleProblem(_ problem: SwedbankPaySDK.Problem) {
        switch problem {
        
        /// Client errors (HTTP Status code in range of 400..499)
        case .Client(.MobileSDK(.InvalidRequest(let message, let raw))):
            printMobileSDKProblem("Client/MobileSDK/InvalidRequest", message: message, raw: raw)
        case .Client(.MobileSDK(.Unauthorized(let message, let raw))):
            printMobileSDKProblem("Client/MobileSDK/Unauthorized", message: message, raw: raw)
        case .Client(.SwedbankPay(let type, let title, let detail, let instance, let action, let problems, let raw)):
            switch type {
            case .Forbidden:
                printSwedbankPayProblem("Client/SwedbankPay/Forbidden", title: title, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            case .InputError:
                printSwedbankPayProblem("Client/SwedbankPay/InputError", title: title, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            case .NotFound:
                printSwedbankPayProblem("Client/SwedbankPay/NotFound", title: title, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            }
        case .Client(.UnexpectedContent(let status, let contentType, let body)):
            printUnexpectedContentProblem("Client/UnexpectedContent", status: status, contentType: contentType, body: body)
        case .Client(.Unknown(let type, let title, let status, let detail, let instance, let raw)):
            printUnknownProblem("Client/Unknown", type: type, title: title, status: status, detail: detail, instance: instance, raw: raw)
        
        /// Server errors (HTTP Status code in range of 500...599)
        case .Server(.MobileSDK(.BackendConnectionFailure(let message, let raw))):
            printMobileSDKProblem("Server/MobileSDK/BackendConnectionFailure", message: message, raw: raw)
        case .Server(.MobileSDK(.BackendConnectionTimeout(let message, let raw))):
            printMobileSDKProblem("Server/MobileSDK/BackendConnectionTimeout", message: message, raw: raw)
        case .Server(.MobileSDK(.InvalidBackendResponse(let body, let raw))):
            printMobileSDKProblem("Server/MobileSDK/InvalidBackendResponse", message: body, raw: raw)
        case .Server(.SwedbankPay(let type, let title, let detail, let instance, let action, let problems, let raw)):
            switch type {
            case .ConfigurationError:
                printSwedbankPayProblem("Server/SwedbankPay/ConfigurationError", title: title, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            case .SystemError:
                printSwedbankPayProblem("Server/SwedbankPay/SystemError", title: title, detail: detail, instance: instance, action: action, problems: problems, raw: raw)
            }
        case .Server(.UnexpectedContent(let status, let contentType, let body)):
            printUnexpectedContentProblem("Server/UnexpectedContent", status: status, contentType: contentType, body: body)
        case .Server(.Unknown(let type, let title, let status, let detail, let instance, let raw)):
            printUnknownProblem("Server/Unknown", type: type, title: title, status: status, detail: detail, instance: instance, raw: raw)
        }
    }
    
    /// Prints out Client or Server MobileSDK `Problem` in a readable format
    private func printMobileSDKProblem(_ errorType: String,
                                       message: String?,
                                       raw: String?)
    {
        print("""
            PROBLEM: \(errorType):
                message: \(message ?? "")
                raw:     \(raw ?? "")
            """)
    }
    
    /// Prints out Client or Server SwedbankPay `Problem` in a readable format
    private func printSwedbankPayProblem(_ errorType: String,
                                         title: String?,
                                         detail: String?,
                                         instance: String?,
                                         action: String?,
                                         problems: [SwedbankPaySDK.SwedbankPaySubProblem]?,
                                         raw: String?)
    {
        print("""
            PROBLEM: \(errorType):
                title:    \(title ?? "")
                detail:   \(detail ?? "")
                instance: \(instance ?? "")
                action:   \(action ?? "")
                problems: {\(getSwedbankPaySubProblemStr(problems))}
                raw:      \(raw ?? "")
            """)
    }
    
    /// Prints out Client or Server UnexpectedContent `Problem` in a readable format
    private func printUnexpectedContentProblem(_ errorType: String,
                                               status: Int,
                                               contentType: String?,
                                               body: String?
                                               )
    {
        print("""
            PROBLEM: \(errorType):
                status:      \(status)
                contentType: \(contentType ?? "")
                body:        \(body ?? "")
            """)
    }
    
    /// Prints out Client or Server Unknown `Problem` in a readable format
    private func printUnknownProblem(_ errorType: String,
                                     type: String?,
                                     title: String?,
                                     status: Int,
                                     detail: String?,
                                     instance: String?,
                                     raw: String?)
    {
        print("""
            PROBLEM: \(errorType):
                type:     \(type ?? "")
                title:    \(title ?? "")
                status:   \(status)
                detail:   \(detail ?? "")
                instance: \(instance ?? "")
                raw:      \(raw ?? "")
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
