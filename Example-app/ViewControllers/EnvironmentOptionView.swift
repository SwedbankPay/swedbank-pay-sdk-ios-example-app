import UIKit

class EnvironmentOptionView : UIView {
    @IBOutlet var label: UILabel!
    @IBOutlet private var underline: UIView!
    
    var onPressed: () -> () = {}
    
    var isSelected: Bool {
        get {
            !underline.isHidden
        }
        set {
            underline.isHidden = !newValue
            label.font = newValue ? .bold12() : .medium12()
        }
    }
    
    @IBAction func onButtonPressed() {
        onPressed()
    }
}
