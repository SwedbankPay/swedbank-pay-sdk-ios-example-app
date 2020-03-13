import UIKit

class EnvironmentSettingsCell : UITableViewCell {
    @IBOutlet private var stageLabel: UILabel!
    @IBOutlet private var stageUnderline: UIView!
    
    @IBOutlet private var externalIntegrationLabel: UILabel!
    @IBOutlet private var externalIntegrationUnderline: UIView!
    
    private var allLabels: [UILabel] {
        return [stageLabel, externalIntegrationLabel]
    }
    private var allUnderlines: [UIView] {
        return [stageUnderline, externalIntegrationUnderline]
    }
    private var selectedOption: (UILabel, UIView) {
        switch PaymentViewModel.shared.environment {
        case .Stage: return (stageLabel, stageUnderline)
        case .ExternalIntegration: return (externalIntegrationLabel, externalIntegrationUnderline)
        }
    }
    
    func refresh() {
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
    
    @IBAction private func onStagePressed() {
        PaymentViewModel.shared.environment = .Stage
        refresh()
    }
    
    @IBAction private func onExternalIntegrationPressed() {
        PaymentViewModel.shared.environment = .ExternalIntegration
        refresh()
    }
}
