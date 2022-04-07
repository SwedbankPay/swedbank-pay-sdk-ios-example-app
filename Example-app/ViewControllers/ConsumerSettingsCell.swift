import UIKit

class ConsumerSettingsCell : SettingsCell {
    @IBOutlet private var anonymousLabel: UILabel!
    @IBOutlet private var anonymousUnderline: UIView!
    
    @IBOutlet private var checkinLabel: UILabel!
    @IBOutlet private var checkinUnderline: UIView!
    
    @IBOutlet private var checkinLabelV3: UILabel!
    @IBOutlet private var checkinUnderlineV3: UIView!
    
    @IBOutlet private var prefillLabel: UILabel!
    @IBOutlet private var prefillUnderline: UIView!
    
    @IBOutlet private var prefillEmailField: UITextField!
    @IBOutlet private var prefillMsisdnField: UITextField!
    @IBOutlet private var prefillProfileRefField: UITextField!
    
    @IBOutlet private var openStateView: UIView!
    @IBOutlet private var openStateConstraints: [NSLayoutConstraint] = []
    
    private var allLabels: [UILabel] {
        return [anonymousLabel, checkinLabel, prefillLabel, checkinLabelV3]
    }
    private var allUnderlines: [UIView] {
        return [anonymousUnderline, checkinUnderline, prefillUnderline, checkinUnderlineV3]
    }
    
    private var selectedOption: (UILabel, UIView) {
        switch ConsumerViewModel.shared.getConsumerType() {
            case .Anonymous: return (anonymousLabel, anonymousUnderline)
            case .Checkin: return (checkinLabel, checkinUnderline)
            case .CheckinV3: return (checkinLabelV3, checkinUnderlineV3)
            case .Prefill: return (prefillLabel, prefillUnderline)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let nc = NotificationCenter.default
                
        let name = UITextField.textDidChangeNotification
        nc.addObserver(self, selector: #selector(onEmailChanged(_:)), name: name, object: prefillEmailField)
        nc.addObserver(self, selector: #selector(onMsisdnChanged(_:)), name: name, object: prefillMsisdnField)
        nc.addObserver(self, selector: #selector(onProfileRefChanged(_:)), name: name, object: prefillProfileRefField)
        
        checkinLabelV3.isHidden = true
        checkinUnderlineV3.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func refresh() {
        refreshOpenState()
        refreshLabels()
        refreshFields()
    }
    
    override func refreshOpenState() {
        let isOpen = ConsumerViewModel.shared.consumerSettingsOpen
        openStateView.alpha = isOpen ? 1 : 0
        if isOpen {
            NSLayoutConstraint.activate(openStateConstraints)
        } else {
            NSLayoutConstraint.deactivate(openStateConstraints)
        }
    }
    
    private func refreshLabels() {
        let (selectedLabel, selectedUnderline) = selectedOption
        for label in allLabels {
            label.font = .medium12()
        }
        for underline in allUnderlines {
            underline.isHidden = true
        }
        selectedLabel.font = .bold12()
        selectedUnderline.isHidden = false
    }
    
    private func refreshFields() {
        prefillEmailField.text = ConsumerViewModel.shared.prefillEmail
        prefillMsisdnField.text = ConsumerViewModel.shared.prefillMsisdn
        prefillProfileRefField.text = ConsumerViewModel.shared.prefillProfileRef
    }

    @IBAction func onOpenPressed(_: Any) {
        onOpenOrCloseButtonPressed?(true)
    }
    
    @IBAction func onClosePressed(_: Any) {
        onOpenOrCloseButtonPressed?(false)
    }
    
    @IBAction func onAnonymousPressed(_: Any) {
        ConsumerViewModel.shared.setConsumerType(.Anonymous)
        refreshLabels()
    }
    
    @IBAction func onCheckinPressed(_ button: UIView) {
        ConsumerViewModel.shared.setConsumerType(.Checkin)
        refreshLabels()
    }
    
    @IBAction func onCheckinPressedV3(_ button: UIView) {
        
        //we wait with checkin: ConsumerViewModel.shared.setConsumerType(.CheckinV3)
        refreshLabels()
    }
    
    @IBAction func onPrefillPressed(_: Any) {
        ConsumerViewModel.shared.setConsumerType(.Prefill)
        refreshLabels()
    }
    
    @objc private func onEmailChanged(_: Notification) {
        ConsumerViewModel.shared.prefillEmail = prefillEmailField.text ?? ""
    }
    
    @objc private func onMsisdnChanged(_: Notification) {
        ConsumerViewModel.shared.prefillMsisdn = prefillMsisdnField.text ?? ""
    }
    
    @objc private func onProfileRefChanged(_: Notification) {
        ConsumerViewModel.shared.prefillProfileRef = prefillProfileRefField.text ?? ""
    }
}

extension ConsumerSettingsCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
