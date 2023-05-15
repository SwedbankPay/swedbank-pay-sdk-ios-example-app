import Foundation
import SwiftUI
import UIKit

class PaymentAlternativesViewController: UIViewController {
    
    @IBSegueAction func showStandaloneUrlView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: StandaloneUrlView())
    }
}
