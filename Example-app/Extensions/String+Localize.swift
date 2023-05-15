import Foundation

extension String {
    var localize: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localize(_ arguments: CVarArg...) -> String {
        return String(format: self.localize, arguments: arguments)
    }
}
