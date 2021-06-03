import UIKit

class SettingsCell : UITableViewCell {
    var onOpenOrCloseButtonPressed: ((_ shouldOpen: Bool) -> Void)?
    func refresh() {}
    func refreshOpenState() {}
    
    func refreshOpenStateAnimated() {
        UIView.animate(withDuration: 0.2) {
            self.refreshOpenState()
            self.layoutIfNeeded()
        }
    }
}
