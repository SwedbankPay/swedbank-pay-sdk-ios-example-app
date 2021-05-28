import UIKit

class GeneralSettingsCell : SettingsCell {
    @IBOutlet private var settingsContainerView: UIView!
    
    @IBOutlet private var norwayUnderlineView: UIView!
    @IBOutlet private var swedenUnderlineView: UIView!
    
    @IBOutlet private var norwayLabel: UILabel!
    @IBOutlet private var swedenLabel: UILabel!
    
    @IBOutlet private var disablePaymentMenuSwitch: UISwitch!
    @IBOutlet private var useSafariSwitch: UISwitch!
    @IBOutlet private var allowAllRedirectsSwitch: UISwitch!
    @IBOutlet private var testWrongHostUrlSwitch: UISwitch!
    
    @IBOutlet private var restrictedToInstrumentsField: UITextField!
    
    @IBOutlet private var instrumentLabel: UILabel!
    
    @IBOutlet private var payerReferenceField: UITextField!
    
    @IBOutlet private var paymentTokenField: UITextField!
    
    @IBOutlet private var generatePaymentTokenSwitch: UISwitch!
    
    @IBOutlet private var subsiteField: UITextField!
    
    @IBOutlet private var settingsOpenConstraints: [NSLayoutConstraint] = []
    
    private var observers: [NSObjectProtocol] = []
    
    var onGetPaymentTokenButtonPressed: () -> () = {}
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nc = NotificationCenter.default
        observers.append(nc.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: restrictedToInstrumentsField, queue: .main
        ) { [weak self] _ in
            self?.onRestrictedToInstrumentsFieldTextChanged()
        })
        observers.append(nc.addObserver(
            forName: PaymentViewModel.InstrumentChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshInstrumentModeLabel()
        })
        observers.append(nc.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: payerReferenceField, queue: .main) { [weak self] _ in
            self?.onPayerReferenceFieldTextChanged()
        })
        observers.append(nc.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: paymentTokenField, queue: .main) { [weak self] _ in
            self?.onPaymentTokenFieldTextChanged()
        })
        observers.append(nc.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: subsiteField, queue: .main) { [weak self] _ in
            self?.onSubsiteFieldTextChanged()
        })
        observers.append(nc.addObserver(
            forName: PaymentViewModel.PaymentTokenChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshPaymentToken()
        })
    }
    
    deinit {
        let nc = NotificationCenter.default
        for observer in observers {
            nc.removeObserver(observer)
        }
    }
    
    override func refresh() {
        refreshOpenState()
        setCountry(ConsumerViewModel.shared.getCountry())
        disablePaymentMenuSwitch.isOn = PaymentViewModel.shared.disablePaymentMenu
        useSafariSwitch.isOn = PaymentViewModel.shared.useSafari
        allowAllRedirectsSwitch.isOn = PaymentViewModel.shared.ignoreGoodRedirectsList
        testWrongHostUrlSwitch.isOn = PaymentViewModel.shared.testWrongHostUrl
        restrictedToInstrumentsField.text = PaymentViewModel.shared.restrictedToInstruments?.joined(separator: ",")
        refreshInstrumentModeLabel()
        refreshPayerReference()
        refreshPaymentToken()
        refreshSubsite()
        generatePaymentTokenSwitch.isOn = PaymentViewModel.shared.generatePaymentToken
    }
    
    override func refreshOpenState() {
        let isOpen = PaymentViewModel.shared.settingsOpen
        settingsContainerView.alpha = isOpen ? 1 : 0
        if isOpen {
            NSLayoutConstraint.activate(settingsOpenConstraints)
        } else {
            NSLayoutConstraint.deactivate(settingsOpenConstraints)
        }
    }
    
    @IBAction func openSettingsButtonClick(_ sender: Any) {
        onOpenOrCloseButtonPressed?(true)
    }
    
    @IBAction func closeSettingsButtonClick(_ sender: Any) {
        onOpenOrCloseButtonPressed?(false)
    }
    
    @IBAction func setCountryNorwayButtonClick(_ sender: Any) {
        setCountry(.Norway)
        ConsumerViewModel.shared.setCountry(.Norway)
    }
    
    @IBAction func setCountrySwedenButtonClick(_ sender: Any) {
        setCountry(.Sweden)
        ConsumerViewModel.shared.setCountry(.Sweden)
    }
    
    @IBAction func onDisablePaymentMenuSwitchValueChanged(_ sender: Any) {
        PaymentViewModel.shared.disablePaymentMenu = disablePaymentMenuSwitch.isOn
    }
    
    @IBAction func onSafariButtonSwitchValueChanged(_ sender: Any) {
        PaymentViewModel.shared.useSafari = useSafariSwitch.isOn
    }
    
    @IBAction func onAllowAllRedirectsSwitchValueChanged(_ sender: Any) {
        PaymentViewModel.shared.ignoreGoodRedirectsList = allowAllRedirectsSwitch.isOn
    }
    
    @IBAction func onTestWrongHostUrlSwitchValueChanged(_ sender: Any) {
        PaymentViewModel.shared.testWrongHostUrl = testWrongHostUrlSwitch.isOn
    }
    
    @IBAction func onSetInstrumentPressed() {
        PaymentViewModel.shared.instrumentPickerOpen = true
    }
    
    private func onRestrictedToInstrumentsFieldTextChanged() {
        let text = self.restrictedToInstrumentsField.text ?? ""
        let instruments = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let instrumentsOrNil = instruments.isEmpty ? nil : instruments
        PaymentViewModel.shared.restrictedToInstruments = instrumentsOrNil
    }
    
    @IBAction func onGeneratePayerReferencePressed() {
        PaymentViewModel.shared.payerReference = UUID().uuidString
        refreshPayerReference()
    }
    
    @IBAction func onLastUsedPayerReferencePressed() {
        PaymentViewModel.shared.setPayerReferenceToLastUsed()
        refreshPayerReference()
    }
    
    private func refreshPayerReference() {
        payerReferenceField.text = PaymentViewModel.shared.payerReference
    }
    
    private func onPayerReferenceFieldTextChanged() {
        if let text = payerReferenceField.text, !text.isEmpty {
            PaymentViewModel.shared.payerReference = text
        } else {
            PaymentViewModel.shared.payerReference = nil
        }
    }
    
    private func onPaymentTokenFieldTextChanged() {
        if let text = paymentTokenField.text, !text.isEmpty {
            PaymentViewModel.shared.paymentToken = text
        } else {
            PaymentViewModel.shared.paymentToken = nil
        }
    }
    
    private func refreshSubsite() {
        subsiteField.text = PaymentViewModel.shared.subsite
    }
    private func onSubsiteFieldTextChanged() {
        if let text = subsiteField.text, !text.isEmpty {
            PaymentViewModel.shared.subsite = text
        } else {
            PaymentViewModel.shared.subsite = nil
        }
    }
    
    @IBAction func getPaymentTokenButtonPressed() {
        onGetPaymentTokenButtonPressed()
    }
    
    private func refreshPaymentToken() {
        paymentTokenField.text = PaymentViewModel.shared.paymentToken
    }
    
    @IBAction func onGeneratePaymentTokenSwitchValueChanged() {
        PaymentViewModel.shared.generatePaymentToken = generatePaymentTokenSwitch.isOn
    }
    
    private func refreshInstrumentModeLabel() {
        instrumentLabel.text = PaymentViewModel.shared.instrument?.rawValue ?? "Disabled"
    }
    
    /// Sets the country in settings view
    private func setCountry(_ country: Country) {
        switch country {
        case .Norway:
            norwayUnderlineView.isHidden = false
            swedenUnderlineView.isHidden = true
            norwayLabel.font = UIFont.bold12()
            swedenLabel.font = UIFont.medium12()
        case .Sweden:
            norwayUnderlineView.isHidden = true
            swedenUnderlineView.isHidden = false
            norwayLabel.font = UIFont.medium12()
            swedenLabel.font = UIFont.bold12()
        }
    }
}

extension GeneralSettingsCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
