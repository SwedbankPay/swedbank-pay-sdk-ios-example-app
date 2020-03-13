import UIKit

class EnvironmentSettingsCell : UITableViewCell {
    @IBOutlet private var testLabel: UILabel!
    @IBOutlet private var testUnderline: UIView!
    
    @IBOutlet private var stageLabel: UILabel!
    @IBOutlet private var stageUnderline: UIView!
    
    private var allLabels: [UILabel] {
        return [testLabel, stageLabel]
    }
    private var allUnderlines: [UIView] {
        return [testUnderline, stageUnderline]
    }
    private var selectedOption: (UILabel, UIView) {
        switch PaymentViewModel.shared.environment {
        case .Test: return (testLabel, testUnderline)
        case .Stage: return (stageLabel, stageUnderline)
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
    
    @IBAction private func onTestPressed() {
        PaymentViewModel.shared.environment = .Test
        refresh()
    }
    
    @IBAction private func onStagePressed() {
        PaymentViewModel.shared.environment = .Stage
        refresh()
    }
}
