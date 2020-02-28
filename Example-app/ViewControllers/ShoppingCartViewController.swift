import UIKit

class ShoppingCartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var shoppingCartView: UIView!
    
    private let settingsContainerTrailingConstant: CGFloat = 93
    private let settingsContainerBottomConstant: CGFloat = 119
    
    private var countryObserver: NSObjectProtocol?
    
    deinit {
        countryObserver.map(NotificationCenter.default.removeObserver)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, belowSubview: shoppingCartView)
        blurEffectView.isHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        countryObserver = NotificationCenter.default.addObserver(forName: .ConsumerViewModelCountryChanged, object: nil, queue: .main) { [weak self] _ in
            self?.updateTableView()
        }
    }
    
    /// Animates the updates in tableView content
    private func updateTableView() {
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .fade)
        if let parent = self.parent as? StoreViewController {
            parent.updateData()
        }
    }
    
    // MARK: Shopping Cart
    
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
    
    private func tableView(_ tableView: UITableView, productCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartProductCell", for: indexPath) as! ShoppingCartProductTableViewCell
        
        let product = StoreViewModel.shared.getBasketProduct(indexPath.row)
        cell.setProductDetails(product)
        
        cell.basketChangedCallback = {
            self.updateTableView()
        }
        
        return cell
    }
    
    private enum Section : CaseIterable {
        case Header
        case Products
        case Footer
        case Settings
        
        var numberOfRows: Int {
            switch self {
            case .Header: return 1
            case .Products: return max(StoreViewModel.shared.getBasketCount(), 1)
            case .Footer: return StoreViewModel.shared.getBasketCount() > 0 ? 1 : 0
            case .Settings: return 1
            }
        }
        
        func getCell(viewController: ShoppingCartViewController, tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
            switch self {
            case .Header: return headerCell(viewController, tableView, indexPath)
            case .Products: return productsCell(viewController, tableView, indexPath)
            case .Footer: return footerCell(viewController, tableView, indexPath)
            case .Settings: return settingsCell(viewController, tableView, indexPath)
            }
        }
        
        private func headerCell(_ viewController: ShoppingCartViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartHeaderCell", for: indexPath) as! ShoppingCartHeaderCell
            cell.onClosePressed = { [weak viewController] in
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
            
            return cell
        }
        
        private func settingsCell(_ viewController: ShoppingCartViewController, _ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            
            cell.refresh()
            
            cell.onOpenPressed = { [weak viewController] in
                if let viewController = viewController {
                    viewController.tableView.beginUpdates()
                    cell.setSettingsOpen(true, animated: true)
                    viewController.tableView.endUpdates()
                }
                
            }
            cell.onClosePressed = { [weak viewController] in
                if let viewController = viewController {
                    viewController.tableView.beginUpdates()
                    cell.setSettingsOpen(false, animated: true)
                    viewController.tableView.endUpdates()
                }
            }
            return cell
        }
    }
}
