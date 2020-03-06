import UIKit

class SettingsCell : UITableViewCell {
    var onOpenOrCloseButtonPressed: ((_ shouldOpen: Bool) -> Void)?
    func refresh() {}
    func refreshOpenStateAnimated() {}
}
