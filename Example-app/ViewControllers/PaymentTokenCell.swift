import UIKit
import SwedbankPaySDK

class PaymentTokenCell : UITableViewCell {
    @IBOutlet private var instrumentLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    
    var onUsePressed: () -> () = {}
    
    @IBAction func onUseButtonPressed() {
        onUsePressed()
    }
    
    func populate(info: SwedbankPaySDK.PaymentTokenInfo) {
        instrumentLabel.text = info.instrument?.rawValue
        nameLabel.text = info.instrumentDisplayName
    }
}
