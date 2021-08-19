import UIKit
import SwedbankPaySDK
import SwedbankPaySDKMerchantBackend


class PayerOwnedPaymentTokensViewController : UIViewController {
    private var request: SwedbankPaySDKRequest? {
        didSet {
            refreshLoadingUI()
        }
    }
    
    private var paymentTokens: [SwedbankPaySDK.PaymentTokenInfo] = [] {
        didSet {
            tokensTableView.reloadData()
        }
    }
    
    @IBOutlet private var tokensTableView: UITableView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private var payerReferenceField: UITextField!
    
    override func viewDidLoad() {
        refreshLoadingUI()
    }
    
    @IBAction func onCurrentButtonPressed() {
        payerReferenceField.text = PaymentViewModel.shared.payerReference
    }
    
    @IBAction func onLastUsedButtonPressed() {
        payerReferenceField.text = PaymentViewModel.shared.getLastUsedPayerReference()
    }
    
    @IBAction func onGetTokensButtonPressed() {
        payerReferenceField.resignFirstResponder()
        if let payerReference = payerReferenceField.text,
           !payerReference.isEmpty {
            getTokens(payerReference: payerReference)
        }
    }
    
    private func getTokens(payerReference: String) {
        request?.cancel()
        
        let configuration = PaymentViewModel.shared.configuration
        request = SwedbankPaySDK.MerchantBackend.getPayerOwnedPaymentTokens(
            configuration: configuration,
            payerReference: payerReference
        ) { [weak self] result in
            self?.onGetTokensResult(result: result)
        }
    }
    
    private func onGetTokensResult(
        result: Result<SwedbankPaySDK.PayerOwnedPaymentTokensResponse, Error>
    ) {
        request = nil
        switch result {
        case .success(let response):
            debugPrint(response)
            paymentTokens = response.payerOwnedPaymentTokens.paymentTokens ?? []
            if paymentTokens.isEmpty {
                showAlert(title: "Note", body: "No payment tokens found")
            }
        case .failure(SwedbankPaySDK.MerchantBackendError.problem(.client(.mobileSDK(.unauthorized)))):
            showAlert(title: "Error", body: "Environment does not support token retrieval")
        case .failure:
            showAlert(title: "Error", body: "Could not retrieve tokens")
        }
    }
    
    private func showAlert(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func useToken(index: Int) {
        PaymentViewModel.shared.paymentToken = paymentTokens[index].paymentToken
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func deleteToken(index: Int) {
        let token = paymentTokens[index]
        
        request?.cancel()
        
        let configuration = PaymentViewModel.shared.configuration
        request = SwedbankPaySDK.MerchantBackend.deletePayerOwnerPaymentToken(
            configuration: configuration,
            paymentToken: token,
            comment: "User deleted from example app"
        ) { [weak self] result in
            self?.onDeleteTokenResult(index: index, result: result)
        }
    }
    
    private func onDeleteTokenResult(
        index: Int,
        result: Result<Void, Error>
    ) {
        request = nil
        
        if case .success = result {
            paymentTokens.remove(at: index)
        }
    }
    
    private func refreshLoadingUI() {
        let loading = request != nil
        loadingIndicator.isHidden = !loading
        if loading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        tokensTableView.alpha = loading ? 0.7 : 1
        tokensTableView.isUserInteractionEnabled = !loading
    }
}

extension PayerOwnedPaymentTokensViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentTokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTokenCell", for: indexPath) as! PaymentTokenCell
        let index = indexPath.row
        cell.onUsePressed = { [weak self] in
            self?.useToken(index: index)
        }
        cell.onDeletePressed = { [weak self] in
            self?.deleteToken(index: index)
        }
        cell.populate(info: paymentTokens[index])
        return cell
    }
}

extension PayerOwnedPaymentTokensViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
