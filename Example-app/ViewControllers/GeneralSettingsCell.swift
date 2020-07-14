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
    
    @IBOutlet private var settingsOpenConstraints: [NSLayoutConstraint] = []
    
    private var restrictedToInstrumentsFieldObserver: NSObjectProtocol?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: restrictedToInstrumentsField, queue: .main) { [weak self] _ in
            self?.onRestrictedToInstrumentsFieldTextChanged()
        }
    }
    
    deinit {
        restrictedToInstrumentsFieldObserver.map(NotificationCenter.default.removeObserver(_:))
    }
    
    override func refresh() {
        refreshOpenState()
        setCountry(ConsumerViewModel.shared.getCountry())
        disablePaymentMenuSwitch.isOn = PaymentViewModel.shared.disablePaymentMenu
        useSafariSwitch.isOn = PaymentViewModel.shared.useSafari
        allowAllRedirectsSwitch.isOn = PaymentViewModel.shared.ignoreGoodRedirectsList
        testWrongHostUrlSwitch.isOn = PaymentViewModel.shared.testWrongHostUrl
        restrictedToInstrumentsField.text = PaymentViewModel.shared.restrictedToInstruments?.joined(separator: ",")
    }
    
    private func refreshOpenState() {
        let isOpen = PaymentViewModel.shared.settingsOpen
        settingsContainerView.alpha = isOpen ? 1 : 0
        if isOpen {
            NSLayoutConstraint.activate(settingsOpenConstraints)
        } else {
            NSLayoutConstraint.deactivate(settingsOpenConstraints)
        }
    }
    
    override func refreshOpenStateAnimated() {
        UIView.animate(withDuration: 0.2) {
            self.refreshOpenState()
            self.layoutIfNeeded()
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
    
    private func onRestrictedToInstrumentsFieldTextChanged() {
        let text = self.restrictedToInstrumentsField.text ?? ""
        let instruments = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let instrumentsOrNil = instruments.isEmpty ? nil : instruments
        PaymentViewModel.shared.restrictedToInstruments = instrumentsOrNil
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
