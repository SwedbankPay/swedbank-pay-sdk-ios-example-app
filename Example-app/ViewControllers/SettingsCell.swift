//
//  SettingsCell.swift
//  Example-app
//
//  Created by Pertti Kroger on 24.2.2020.
//  Copyright © 2020 Swedbank. All rights reserved.
//

import UIKit

class SettingsCell : UITableViewCell {
    @IBOutlet private var settingsContainerView: UIView!
    
    @IBOutlet private var anonymousUnderlineView: UIView!
    @IBOutlet private var identifiedUnderlineView: UIView!
    @IBOutlet private var norwayUnderlineView: UIView!
    @IBOutlet private var swedenUnderlineView: UIView!
    
    @IBOutlet private var anonymousLabel: UILabel!
    @IBOutlet private var identifiedLabel: UILabel!
    @IBOutlet private var norwayLabel: UILabel!
    @IBOutlet private var swedenLabel: UILabel!
    
    @IBOutlet private var disablePaymentMenuSwitch: UISwitch!
    @IBOutlet private var useSafariSwitch: UISwitch!
    @IBOutlet private var testWrongHostUrlSwitch: UISwitch!
    
    @IBOutlet private var restrictedToInstrumentsField: UITextField!
    
    @IBOutlet private var settingsOpenConstraints: [NSLayoutConstraint] = []
    
    private var restrictedToInstrumentsFieldObserver: NSObjectProtocol?
    
    var onOpenPressed: (() -> Void)?
    
    var onClosePressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: restrictedToInstrumentsField, queue: .main) { [weak self] _ in
            self?.onRestrictedToInstrumentsFieldTextChanged()
        }
    }
    
    deinit {
        restrictedToInstrumentsFieldObserver.map(NotificationCenter.default.removeObserver(_:))
    }
    
    func refresh() {
        setSettingsOpen(PaymentViewModel.shared.settingsOpen, animated: false)
        setCountry(ConsumerViewModel.shared.getCountry())
        setConsumer(ConsumerViewModel.shared.getConsumerType())
        disablePaymentMenuSwitch.isOn = PaymentViewModel.shared.disablePaymentMenu
        useSafariSwitch.isOn = PaymentViewModel.shared.useSafari
        testWrongHostUrlSwitch.isOn = PaymentViewModel.shared.testWrongHostUrl
        restrictedToInstrumentsField.text = PaymentViewModel.shared.restrictedToInstruments?.joined(separator: ",")
    }
    
    @IBAction func openSettingsButtonClick(_ sender: Any) {
        onOpenPressed?()
    }
    
    @IBAction func closeSettingsButtonClick(_ sender: Any) {
        onClosePressed?()
    }
    
    @IBAction func setAnonymousButtonClick(_ sender: Any) {
        setConsumer(.Anonymous)
    }
    
    @IBAction func setIdentifiedButtonClick(_ sender: Any) {
        setConsumer(.Identified)
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
    
    @IBAction func onTestWrongHostUrlSwitchValueChanged(_ sender: Any) {
        PaymentViewModel.shared.testWrongHostUrl = testWrongHostUrlSwitch.isOn
    }
    
    private func onRestrictedToInstrumentsFieldTextChanged() {
        let text = self.restrictedToInstrumentsField.text ?? ""
        let instruments = text.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        let instrumentsOrNil = instruments.isEmpty ? nil : instruments
        PaymentViewModel.shared.restrictedToInstruments = instrumentsOrNil
    }
    
    func setSettingsOpen(_ open: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.setSettingsOpen(open)
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            setSettingsOpen(open)
        }
    }
    
    private func setSettingsOpen(_ open: Bool) {
        PaymentViewModel.shared.settingsOpen = open
        settingsContainerView.alpha = open ? 1 : 0
        if open {
            NSLayoutConstraint.activate(settingsOpenConstraints)
        } else {
            NSLayoutConstraint.deactivate(settingsOpenConstraints)
        }
    }
    
    private func setSettingsClosed() {
        settingsContainerView.alpha = 0
        NSLayoutConstraint.deactivate(settingsOpenConstraints)
    }
    
    /// Sets the `Consumer` either anonymous or identified in settings view
    private func setConsumer(_ type: ConsumerType) {
        ConsumerViewModel.shared.setConsumerType(type)
        switch type {
        case .Anonymous:
            anonymousUnderlineView.isHidden = false
            identifiedUnderlineView.isHidden = true
            anonymousLabel.font = UIFont.bold12()
            identifiedLabel.font = UIFont.medium12()
        case .Identified:
            anonymousUnderlineView.isHidden = true
            identifiedUnderlineView.isHidden = false
            anonymousLabel.font = UIFont.medium12()
            identifiedLabel.font = UIFont.bold12()
        }
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

extension SettingsCell : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
