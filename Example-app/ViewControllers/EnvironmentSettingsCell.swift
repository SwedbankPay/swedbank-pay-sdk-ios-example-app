import UIKit

private extension PaymentViewModel.Environment {
    var displayName: String {
        switch self {
        case .Stage:
            return "Stage"
        case .ExternalIntegration:
            return "Ext. Integration"
        case .PaymentPagesExternalIntegration:
            return "PaymentPages (EI)"
        case .BadRedirectDemo:
            return "Bad Redirect"
        #if PROD_DEMO
        case .Prod:
            return "Prod"
        #endif
        }
    }
}

class EnvironmentSettingsCell : UITableViewCell {
    private struct Option {
        let environment: PaymentViewModel.Environment
        let view: EnvironmentOptionView
    }
    private let options = createOptions()
    
    @IBOutlet private var environmentOptionsLeftColumn: UIStackView?
    @IBOutlet private var environmentOptionsRightColumn: UIStackView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addOptionViews()
        refresh()
    }
    
    private static func createOptions() -> [Option] {
        let nib = UINib(nibName: "EnvironmentOptionView", bundle: nil)
        return PaymentViewModel.Environment.allCases.map { env in
            let view = nib.instantiate(withOwner: nil, options: nil).first as! EnvironmentOptionView
            view.label.text = env.displayName
            return Option(
                environment: env,
                view: view
            )
        }
    }
    
    private func addOptionViews() {
        for (index, option) in options.enumerated() {
            let column = index % 2 == 0
                ? environmentOptionsLeftColumn
                : environmentOptionsRightColumn
            column?.addArrangedSubview(option.view)
            option.view.onPressed = { [weak self] in
                self?.setEnvironment(option.environment)
            }
        }
    }
    
    private func setEnvironment(_ environment: PaymentViewModel.Environment) {
        PaymentViewModel.shared.environment = environment
        refresh()
    }
    
    func refresh() {
        let environment = PaymentViewModel.shared.environment
        for option in options {
            option.view.isSelected = option.environment == environment
        }
    }
}
