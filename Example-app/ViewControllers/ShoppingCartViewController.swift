import UIKit
import SwedbankPaySDK
import SwiftUI

private let animationDuration: TimeInterval = 0.5

class ShoppingCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView?
    @IBOutlet private weak var shoppingCartView: UIView!
    @IBOutlet private var instrumentPickerContainer: UIView!
    @IBOutlet private var instrumentPicker: UIPickerView!
    @IBOutlet private var instrumentPickerVisibleConstraint: NSLayoutConstraint!
    @IBOutlet private var instrumentPickerHiddenConstraint: NSLayoutConstraint!
    @IBOutlet private var customInstrumentField: UITextField!
    @IBOutlet private var customInstrumentFieldBottomConstraint: NSLayoutConstraint!
    
    private var countryObserver: NSObjectProtocol?
    private var instrumentPickerOpenObserver: NSObjectProtocol?
    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?
        
    deinit {
        countryObserver.map(NotificationCenter.default.removeObserver)
        instrumentPickerOpenObserver.map(NotificationCenter.default.removeObserver)
        keyboardWillShowObserver.map(NotificationCenter.default.removeObserver)
        keyboardWillHideObserver.map(NotificationCenter.default.removeObserver)
    }
    
    var tableViewController: UITableViewController!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedShoppingCartTableView" {
            tableViewController = segue.destination as? UITableViewController
            let tableView = tableViewController.tableView
            self.tableView = tableView
            tableView?.dataSource = self
            tableView?.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, belowSubview: shoppingCartView)
        blurEffectView.isHidden = false
        
        countryObserver = NotificationCenter.default.addObserver(forName: .ConsumerViewModelCountryChanged, object: nil, queue: .main) { [weak self] _ in
            self?.updateTableView()
        }
        
        hideOrShowInstrumentPickerIfNeeded(animated: false)
        initializeInstrumentPicker()
        instrumentPickerOpenObserver = NotificationCenter.default.addObserver(
            forName: PaymentViewModel.InstrumentPickerOpenChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.hideOrShowInstrumentPickerIfNeeded(animated: true)
        }
        
        keyboardWillShowObserver = NotificationCenter.default.addObserver(
            forName: Self.keyboardWillShowNotification, object: nil, queue: .main
        ) { [weak self] note in
            if let self = self {
                let frameValue = note.userInfo?[Self.keyboardFrameEndUserInfoKey] as? NSValue
                let frame = frameValue?.cgRectValue
                frame.map(self.updateCustomInstrumentFieldBottomConstraint(keyboardFrame:))
            }
        }
        
        keyboardWillHideObserver = NotificationCenter.default.addObserver(
            forName: Self.keyboardWillHideNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.updateCustomInstrumentFieldBottomConstraint(keyboardFrame: nil)
        }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideOrShowInstrumentPickerIfNeeded(animated: false)
    }
    
    /// Animates the updates in tableView content
    private func updateTableView() {
        if let tableView = tableView {
            let range = NSMakeRange(0, tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            tableView.reloadSections(sections as IndexSet, with: .fade)
            if let parent = self.parent as? StoreViewController {
                parent.updateData()
            }
        }
    }
    
    // MARK: Shopping Cart
    
    private func changeTotal() {
        guard presentedViewController == nil else {
            return
        }
        
        let alert = UIAlertController(title: "Set total", message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.keyboardType = .decimalPad
        }
        alert.addAction(.init(title: "OK", style: .default) { [weak self] _ in
            let text = alert.textFields?.first?.text ?? ""
            let total = text.isEmpty ? nil : Decimal.init(string: text, locale: .current)
            StoreViewModel.shared.overrideTotal = total.map {
                (($0 * Decimal(100)) as NSDecimalNumber).intValue
            }
            self?.updateTableView()
        })
        present(alert, animated: true, completion: nil)
    }
    
    /// Hides the shopping cart and shows the payment view
    private func checkout() {
        if StoreViewModel.shared.getBasketCount() > 0 {
            if let parent = self.parent as? StoreViewController {
                hideShoppingCart()
                parent.startPayment()
            }
        }
    }
    
    /// Hides the shopping cart view
    private func hideShoppingCart() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        if let parent = self.parent as? StoreViewController {
            parent.hideShoppingCart()
        }
    }
    
    private func showGetTokens() {
        performSegue(withIdentifier: "presentGetTokens", sender: nil)
    }
    
    
    // MARK: TableView delegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Section.allCases[section].numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return Section.allCases[indexPath.section].getCell(viewController: self, tableView: tableView, indexPath: indexPath)
    }
    
    private enum Section: CaseIterable {
        case Environment
        case Header
        case Products
        case Footer
        case Settings
        
        var numberOfRows: Int {
            switch self {
                case .Environment: return 1
                case .Header: return 1
                case .Products: return max(StoreViewModel.shared.getBasketCount(), 1)
                case .Footer: return StoreViewModel.shared.getBasketCount() > 0 ? 1 : 0
                case .Settings: return SettingsRow.allCases.count
            }
        }
        
        func getCell(viewController: ShoppingCartViewController, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            switch self {
                case .Environment: return environmentCell(viewController, tableView, indexPath)
                case .Header: return headerCell(viewController, tableView, indexPath)
                case .Products: return productsCell(viewController, tableView, indexPath)
                case .Footer: return footerCell(viewController, tableView, indexPath)
                case .Settings: return SettingsRow.allCases[indexPath.row].getCell(viewController: viewController, tableView: tableView, indexPath: indexPath)
            }
        }
        
        private func environmentCell(_ viewController: ShoppingCartViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EnvironmentSettingsCell", for: indexPath) as! EnvironmentSettingsCell
            cell.refresh()
            return cell
        }
        
        private func headerCell(_ viewController: ShoppingCartViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartHeaderCell", for: indexPath) as! ShoppingCartHeaderCell
            cell.onClosePressed = { [weak viewController] in
                PaymentViewModel.shared.instrumentPickerOpen = false
                viewController?.hideShoppingCart()
            }
            return cell
        }
        
        private func productsCell(_ viewController: ShoppingCartViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let vm = StoreViewModel.shared
            if vm.getBasketCount() == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "ShoppingCartEmptyCell", for: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartProductTableViewCell", for: indexPath) as! ShoppingCartProductTableViewCell
                
                let product = vm.getBasketProduct(indexPath.row)
                cell.setProductDetails(product)
                
                cell.basketChangedCallback = { [weak viewController] in
                    viewController?.updateTableView()
                }
                
                return cell
            }
        }
        
        private func footerCell(_ viewController: ShoppingCartViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartSummaryFooterCell", for: indexPath) as! ShoppingCartSummaryFooterCell
            cell.setPrices()
            
            cell.checkoutCallback = { [weak viewController] in
                viewController?.checkout()
            }
            cell.onChangeTotalPressed = { [weak viewController] in
                viewController?.changeTotal()
            }
            
            return cell
        }
    }
    
    private enum SettingsRow : CaseIterable {
        case Consumer
        case General
        case Style
        
        private var cellIdentifier: String {
            switch self {
            case .Consumer: return "ConsumerSettingsCell"
            case .General: return "GeneralSettingsCell"
            case .Style: return "StyleSettingsCell"
            }
        }
        
        private func setOpen(_ open: Bool) {
            switch self {
            case .Consumer:
                ConsumerViewModel.shared.consumerSettingsOpen = open
            case .General:
                PaymentViewModel.shared.settingsOpen = open
            case .Style:
                PaymentViewModel.shared.styleOpen = open
            }
        }
        
        func getCell(viewController: ShoppingCartViewController, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsCell
            cell.refresh()
            cell.onOpenOrCloseButtonPressed = { [weak viewController] shouldOpen in
                if let tableView = viewController?.tableView {
                    self.setOpen(shouldOpen)
                    tableView.beginUpdates()
                    cell.refreshOpenStateAnimated()
                    tableView.endUpdates()
                }
            }
            if self == .General, let cell = cell as? GeneralSettingsCell {
                 cell.onGetPaymentTokenButtonPressed = { [weak viewController] in
                    viewController?.showGetTokens()
                }
            }
            return cell
        }
    }
}

// MARK: Instrument picker

extension ShoppingCartViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    private func initializeInstrumentPicker() {
        instrumentPicker.dataSource = self
        instrumentPicker.delegate = self
        
        instrumentPicker.selectRow(PaymentViewModel.shared.instrumentOptionIndex, inComponent: 0, animated: false)
        customInstrumentField.text = PaymentViewModel.shared.customInstrument
        updateCustomInstrumentFieldVisibility()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onCustomInstrumentFieldTextChanged),
            name: UITextField.textDidChangeNotification,
            object: customInstrumentField
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCustomInstrumentFieldVisibility),
            name: PaymentViewModel.InstrumentChangedNotification,
            object: nil
        )
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PaymentViewModel.shared.instrumentOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PaymentViewModel.shared.instrumentOptions[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        PaymentViewModel.shared.instrumentOptionIndex = row
    }
    @objc private func onCustomInstrumentFieldTextChanged() {
        if let text = customInstrumentField.text, !text.isEmpty {
            PaymentViewModel.shared.customInstrument = text
        } else {
            PaymentViewModel.shared.customInstrument = nil
        }
    }
    
    @objc private func updateCustomInstrumentFieldVisibility() {
        switch PaymentViewModel.shared.instrumentOption {
        case .custom:
            customInstrumentField.isHidden = false
        default:
            customInstrumentField.isHidden = true
        }
    }
    
    private func updateCustomInstrumentFieldBottomConstraint(keyboardFrame: CGRect?) {
        if let keyboardFrame = keyboardFrame {
            let view = self.view!
            let keyboardFrameInView = view.convert(
                keyboardFrame,
                from: UIScreen.main.coordinateSpace
            )
            let keyboardTopInView = keyboardFrameInView.minY
            let viewBottom = view.bounds.maxY
            let keyboardHeightInView = viewBottom - keyboardTopInView
            customInstrumentFieldBottomConstraint.constant = keyboardHeightInView
        }
        customInstrumentFieldBottomConstraint.isActive = keyboardFrame != nil
    }
    
    private func hideOrShowInstrumentPickerIfNeeded(animated: Bool) {
        let visible = PaymentViewModel.shared.instrumentPickerOpen
        instrumentPickerContainer.isUserInteractionEnabled = visible
        let activeConstraint = visible ? instrumentPickerVisibleConstraint : instrumentPickerHiddenConstraint
        let inactiveConstraint = visible ? instrumentPickerHiddenConstraint : instrumentPickerVisibleConstraint
        UIView.animate(withDuration: animated ? animationDuration : 0) {
            inactiveConstraint?.isActive = false
            activeConstraint?.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onCloseInstrumentPickerPressed() {
        customInstrumentField.resignFirstResponder()
        PaymentViewModel.shared.instrumentPickerOpen = false
    }
}

extension ShoppingCartViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
