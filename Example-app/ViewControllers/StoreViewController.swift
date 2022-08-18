import UIKit
import Combine

class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var basketCounterView: UIView!
    @IBOutlet private weak var basketCounterLabel: UILabel!
    @IBOutlet private weak var shoppingCartView: UIView!
    
    private var shoppingCartVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductCell")

        if #available(iOS 13, *) {
            self.navigationController?.overrideUserInterfaceStyle = UIUserInterfaceStyle.light
        } else {
            if let navigationBar = navigationController?.navigationBar {
                navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationBar.shadowImage = UIImage()
                navigationBar.layoutIfNeeded()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = ""
        
        basketCounterView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        shoppingCartView.isHidden = true
        
        updateBasketCounter()
        
        tableView.reloadData()
    }
    
    /// Updates the shopping cart counter with animation
    private func updateBasketCounter() {
        let count = StoreViewModel.shared.getBasketCount()
        basketCounterView.isHidden = (count > 0) ? false : true
        if count > 0 {
            if basketCounterLabel.text != String(count) {
                UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                    self?.basketCounterView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }, completion: { [weak self] _ in
                    UIView.animate(withDuration: 0.05, delay: 0.02, options: .curveEaseInOut, animations: { [weak self] in
                        self?.basketCounterView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }, completion: { [weak self] _ in
                        UIView.animate(withDuration: 0.05, delay: 0.02, options: .curveEaseInOut, animations: { [weak self] in
                            self?.basketCounterView.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }, completion: nil)
                    })
                })
            }
            basketCounterLabel.text = String(count)
        } else {
            basketCounterLabel.text = "0"
        }
    }
    
    func updateData() {
        updateBasketCounter()
        tableView.reloadData()
    }
    
    /// Shows the payment view
    func startPayment() {
        self.title = "Cancel"
        PaymentViewModel.shared.lastPaymentNavigationLog = []
        PaymentViewModel.shared.errorLog = []
        performSegue(withIdentifier: "showPayment", sender: self)
        if let payerReference = PaymentViewModel.shared.payerReference {
            PaymentViewModel.shared.saveLastUsedPayerReference(payerReference: payerReference)
        }
    }
    
    // MARK: IBActions
    
    @IBAction func checkoutButtonClick(_ sender: Any) {
        showShoppingCart()
    }
    
    @IBAction func unwindToStore(_ unwindSegue: UIStoryboardSegue) {}
    
    // MARK: Shopping Cart
    
    /// SwiftUI specialized view models
    private lazy var storeViewModel = StoreViewModelObserved()
    private lazy var consumerModel = ConsumerSettingsViewModel()
    private lazy var settingsViewModel = GeneralSettingsViewModel()
    private lazy var styleModel = StyleSettingsModel()
    
    /// Listener for SwiftUI callbacks
    private var listeners = Set<AnyCancellable>()
    
    /// SwiftUI background is handled by UIKit
    private var blurView: UIVisualEffectView?
    
    /// Shows the shopping cart with animation (creates the shopping cart view as a child viewcontroller inside shoppingCartView)
    private func showShoppingCart() {
        navigationController?.navigationBar.alpha = 0.001
        shoppingCartView.isHidden = false
        shoppingCartView.alpha = 0
        
        showShoppingCartSwiftUI()
        if let vc = shoppingCartVC {
            addChild(vc)
            shoppingCartView.addSubview(vc.view)
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            
            vc.view.backgroundColor = UIColor.clear
            
            NSLayoutConstraint.activate([
                vc.view.topAnchor.constraint(equalTo: shoppingCartView.topAnchor),
                vc.view.leftAnchor.constraint(equalTo: shoppingCartView.leftAnchor, constant: 20),
                vc.view.rightAnchor.constraint(equalTo: shoppingCartView.rightAnchor, constant: -20),
                vc.view.bottomAnchor.constraint(equalTo: shoppingCartView.bottomAnchor),
            ])
            
            vc.didMove(toParent: self)
        }
        view.bringSubviewToFront(shoppingCartView)

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.shoppingCartView.alpha = 1
        })
    }
    
    /// Setting up and handling the SwiftUI hooks
    private func showShoppingCartSwiftUI() {
        
        storeViewModel.showBasket = true
        shoppingCartVC = ShoppingCartTable(storeViewModel: storeViewModel, settingsViewModel: settingsViewModel, consumerModel: consumerModel, styleModel: styleModel).hostingController
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurView = blurEffectView
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, belowSubview: shoppingCartView)
        storeViewModel.$showBasket.sink { [self] showBasket in
            if showBasket == false {
                hideShoppingCart()
                listeners.removeAll()
            }
        }.store(in: &listeners)
        
        storeViewModel.$processPayment.sink { [self] processPayment in
            if processPayment {
                DispatchQueue.main.async {
                    self.storeViewModel.processPayment = false
                }
                hideShoppingCart()
                listeners.removeAll()
                startPayment()
            }
        }.store(in: &listeners)
    }
    
    /// Hides the shopping cart with animation, updates the shopping cart counter
    func hideShoppingCart() {
        
        updateBasketCounter()

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.shoppingCartView.alpha = 0
            self?.blurView?.alpha = 0
        }, completion: { [weak self] _ in
            
            if let vc = self?.shoppingCartVC {
                vc.willMove(toParent: nil)
                vc.view.removeFromSuperview()
                vc.removeFromParent()
            }
            self?.shoppingCartVC = nil
            self?.shoppingCartView.isHidden = true
            self?.blurView?.removeFromSuperview()
            self?.blurView = nil
            
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        })
    }
    
    // MARK: TableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StoreViewModel.shared.products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 395
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        label.text = "Shoes"
        label.font = UIFont.medium24()
        label.textColor = UIColor.black
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white    
        
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell
        
        if StoreViewModel.shared.products.count > indexPath.row {
            let product = StoreViewModel.shared.products[indexPath.row]
            cell.setProductDetails(product)
        }
        
        cell.basketChangedCallback = {
            self.updateBasketCounter()
        }
        
        return cell
    }
}
