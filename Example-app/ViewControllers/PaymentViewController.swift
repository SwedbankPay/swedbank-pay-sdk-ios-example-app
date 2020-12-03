import UIKit
import SwedbankPaySDK

private let animationDuration: TimeInterval = 0.5

class PaymentViewController: UIViewController {
    
    private var swedbankPaySDKController: SwedbankPaySDKController?
    
    /// UIView to instantiate the SwedbankPaySDKController into; SwedbankPaySDKController will instantiate WKWebView
    @IBOutlet private weak var webViewContainer: UIView!
    @IBOutlet private var instrumentArea: UIView!
    @IBOutlet private var instrumentLabel: UILabel!
    @IBOutlet private var instrumentPicker: UIPickerView!
    @IBOutlet private var instrumentPickerVisibleConstraint: NSLayoutConstraint!
    
    @IBOutlet private var updatingView: UIView!
    @IBOutlet private var updatingIndicator: UIActivityIndicatorView!
        
    private var paymentLog: [URL] = []
    
    private var indexOfInstrumentToSet: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateInstrumentUI()
    }
    
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
        self.swedbankPaySDKController = swedbankPaySDKController
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
        
        updateInstrumentUI()
    }
    
    private func updateInstrumentUI() {
        let showingPayment = swedbankPaySDKController?.showingPaymentOrder == true
        let info = showingPayment ? swedbankPaySDKController?.currentPaymentOrder : nil
        let instrument = info?.instrument
        let hidden = instrument == nil
        instrumentArea.isHidden = hidden
        instrumentLabel.text = instrument?.displayName
        instrumentPicker.reloadComponent(0)
        
        if instrument == nil {
            setInstrumentPickerVisible(false, animated: false)
        }
        if info?.availableInstruments?.isEmpty == false {
            indexOfInstrumentToSet = 0
            instrumentPicker.selectRow(0, inComponent: 0, animated: false)
        } else {
            indexOfInstrumentToSet = nil
        }
        
        updateUpdatingUI()
    }
    
    private func updateUpdatingUI() {
        let updating = swedbankPaySDKController?.updatingPaymentOrder == true
        updatingView.isHidden = !updating
        if updating {
            updatingIndicator.startAnimating()
        } else {
            updatingIndicator.stopAnimating()
        }
    }
    
    @IBAction func openInstrumentPicker() {
        if let index = indexOfInstrumentToSet {
            instrumentPicker.selectRow(index, inComponent: 0, animated: false)
        }
        setInstrumentPickerVisible(true, animated: true)
    }
    
    @IBAction func cancelSetInstrument() {
        setInstrumentPickerVisible(false, animated: true)
    }
    
    @IBAction func confirmSetInstrument() {
        setInstrumentPickerVisible(false, animated: true)
        if let controller = swedbankPaySDKController,
           let index = indexOfInstrumentToSet,
           let instruments = controller.currentPaymentOrder?.availableInstruments {
            let instrument = instruments[index]
            
            controller.updatePaymentOrder(updateInfo: instrument)
            updateUpdatingUI()
        }
    }
    
    private func setInstrumentPickerVisible(_ visible: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? animationDuration : 0) {
            self.instrumentPickerVisibleConstraint.isActive = visible
            self.view.layoutIfNeeded()
        }
    }
}

/// Need to conform to SwedbankPaySDKDelegate protocol
extension PaymentViewController: SwedbankPaySDKDelegate {
    func paymentOrderDidShow(info: SwedbankPaySDK.ViewPaymentOrderInfo) {
        updateInstrumentUI()
    }
    
    func paymentOrderDidHide() {
        updateInstrumentUI()
    }
    
    func paymentComplete() {
        PaymentViewModel.shared.setResult(.success)
        performSegue(withIdentifier: "showResult", sender: self)
    }
    
    func paymentFailed(error: Error) {
        PaymentViewModel.shared.setResult(.error(error))
        performSegue(withIdentifier: "showResult", sender: self)
    }
    
    func paymentCanceled() {
        PaymentViewModel.shared.setResult(.unknown)
        performSegue(withIdentifier: "backToStore", sender: self)
    }
    
    func updatePaymentOrderFailed(updateInfo: Any, error: Error) {
        updateInstrumentUI()
        
        if let instrument = updateInfo as? SwedbankPaySDK.Instrument {
            showUpdateInstrumentErrorDialog(instrument: instrument, error: error)
        }
    }
    
    private func showUpdateInstrumentErrorDialog(instrument: SwedbankPaySDK.Instrument, error: Error) {
        let message = getSetInstrumentErrorMessage(instrument: instrument, error: error)
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    private func getSetInstrumentErrorMessage(instrument: SwedbankPaySDK.Instrument, error: Error) -> String {
        if case SwedbankPaySDK.MerchantBackendError.problem(.client) = error {
            return "\(instrument.displayName) is not valid for this payment"
        } else {
            return "Unable to change instrument"
        }
    }
}

extension PaymentViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let instruments = swedbankPaySDKController?.currentPaymentOrder?.availableInstruments
        return instruments?.count ?? 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let instruments = swedbankPaySDKController?.currentPaymentOrder?.availableInstruments
        return instruments?[row].displayName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        indexOfInstrumentToSet = row
    }
}
