import Foundation

struct StorageHelper {
    
    enum Key: String, CaseIterable {
        case baseUrl
        case completeUrl
        case cancelUrl
        case useCheckoutV3
        case paymentUrl
        
        var storageString: String {
            return "Storage\(self.rawValue)"
        }
    }
    
    static let shared = StorageHelper()
    
    private let store = UserDefaults.standard
    
    // MARK: Generic methods
    func save<T>(value: T, forKey key: Key) {
        store.set(value, forKey: key.storageString)
    }
    
    func value<T>(for key: Key) -> T? {
        return store.value(forKey: key.storageString) as? T
    }
}
