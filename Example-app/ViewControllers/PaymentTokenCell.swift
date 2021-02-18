import UIKit
import SwedbankPaySDK

class PaymentTokenCell : UITableViewCell {
    @IBOutlet private var instrumentLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    
    var onUsePressed: () -> () = {}
    
    var onDeletePressed: () -> () = {}
    
    @IBAction func onUseButtonPressed() {
        onUsePressed()
    }
    
    @IBAction func onDeleteButtonPressed() {
        onDeletePressed()
    }
    
    func populate(info: SwedbankPaySDK.PaymentTokenInfo) {
        instrumentLabel.text = info.instrument?.rawValue
        nameLabel.text = info.instrumentDisplayName
    }
}
