import UIKit

class StyleSettingsCell: SettingsCell {
    @IBOutlet private var styleInput: UITextView!
    
    @IBOutlet private var openStateView: UIView!
    @IBOutlet private var openStateConstraints: [NSLayoutConstraint] = []
    
    @IBOutlet private var doneButton: UIButton!
    
    @IBOutlet private var errorLabel: UILabel!
    
    override func refresh() {
        refreshOpenState()
        refreshDoneButtonState()
        refreshErrorState()
        styleInput.text = PaymentViewModel.shared.styleText
    }
    
    override func refreshOpenState() {
        let isOpen = PaymentViewModel.shared.styleOpen
        openStateView.alpha = isOpen ? 1 : 0
        if isOpen {
            NSLayoutConstraint.activate(openStateConstraints)
        } else {
            NSLayoutConstraint.deactivate(openStateConstraints)
        }
    }
    
    private func refreshDoneButtonState() {
        doneButton.isHidden = !styleInput.isFirstResponder
    }
    
    private func refreshErrorState() {
        let vm = PaymentViewModel.shared
        let hasError = !vm.trimmedStyleText.isEmpty && vm.style == nil
        errorLabel.alpha = hasError ? 1 : 0
    }
    
    @IBAction func onOpenPressed() {
        let wasOpen = PaymentViewModel.shared.styleOpen
        onOpenOrCloseButtonPressed?(true)
        if !wasOpen {
            styleInput.becomeFirstResponder()
        }
    }
    
    @IBAction func onClosePressed() {
        styleInput.resignFirstResponder()
        onOpenOrCloseButtonPressed?(false)
    }
    
    @IBAction func onDoneButtonPressed() {
        styleInput.resignFirstResponder()
    }
}

extension StyleSettingsCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        refreshDoneButtonState()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        refreshDoneButtonState()
        refreshErrorState()
    }
    func textViewDidChange(_ textView: UITextView) {
        PaymentViewModel.shared.styleText = styleInput.text
    }
}
