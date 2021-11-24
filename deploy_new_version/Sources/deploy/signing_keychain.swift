import Foundation
import Security

struct KeychainError: Error {
    var description: String
}
extension KeychainError: LocalizedError {
    var errorDescription: String? {
        description
    }
}

func withKeychain(at url: URL, operation: (SecKeychain) throws -> Void) throws {
    let keychainPassword = try makeKeychainPassword()
    
    let keychain = try createSigningKeychain(at: url, password: keychainPassword)
    defer {
        SecKeychainDelete(keychain)
    }
    
    try unlockKeychain(keychain: keychain, password: keychainPassword)
    try addToSearchList(keychain: keychain)
    try operation(keychain)
}

private func makeKeychainPassword() throws -> Data {
    var password = Data(count: 15)
    try password.withUnsafeMutableBytes {
        try checkSuccess(SecRandomCopyBytes(kSecRandomDefault, $0.count, $0.baseAddress!))
    }
    return password.base64EncodedData()
}

private func createSigningKeychain(at url: URL, password: Data) throws -> SecKeychain {
    var keychain: SecKeychain? = nil
    
    try url.withUnsafeFileSystemRepresentation { path in
        guard let path = path else {
            throw KeychainError(description: "Unexpected: unable to get file system path for keychain url")
        }
        try password.withUnsafeBytes {
            try checkSuccess(SecKeychainCreate(
                path,
                UInt32($0.count),
                $0.baseAddress,
                false, // promptUser
                nil, // initialAccess
                &keychain
            ))
        }
    }
    
    return keychain!
}

private func unlockKeychain(keychain: SecKeychain, password: Data) throws {
    var settings = SecKeychainSettings(
        version: UInt32(SEC_KEYCHAIN_SETTINGS_VERS1),
        lockOnSleep: false,
        useLockInterval: false,
        lockInterval: UInt32(INT_MAX)
    )
    try checkSuccess(SecKeychainSetSettings(keychain, &settings))
    try password.withUnsafeBytes {
        try checkSuccess(SecKeychainUnlock(keychain, UInt32($0.count), $0.baseAddress, true))
    }
}

private func addToSearchList(keychain: SecKeychain) throws {
    var searchList: CFArray? = nil
    try checkSuccess(SecKeychainCopySearchList(&searchList))
    var newSearchList = (searchList as Array?) ?? []
    newSearchList.append(keychain)
    try checkSuccess(SecKeychainSetSearchList(newSearchList as CFArray))
}
