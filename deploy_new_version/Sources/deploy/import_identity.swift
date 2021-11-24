import Foundation
import Security

struct BadIdentityError: Error {
    var description: String
}
extension BadIdentityError: LocalizedError {
    var errorDescription: String? {
        description
    }
}

/// - returns: the common name of the signing certificate
func importIdentity(keychain: SecKeychain, data: Data, password: String) throws -> String {
    var items: CFArray? = nil
    try checkSuccess(SecPKCS12Import(data as CFData, [
        kSecImportExportPassphrase: password,
        kSecImportExportKeychain: keychain,
        kSecImportExportAccess: createAllowedAccess()
    ] as CFDictionary, &items))
    
    guard let items = items as Array?, !items.isEmpty else {
        throw BadIdentityError(description: "No items in identity blob")
    }
    let identities = items.compactMap { ($0 as? NSDictionary)?[kSecImportItemIdentity] }
    guard let identity = identities.first else {
        throw BadIdentityError(description: "No identities in identity blob")
    }
    guard identities.count == 1 else {
        throw BadIdentityError(description: "Identity blob contains more that one identity")
    }
    var certificate: SecCertificate? = nil
    try checkSuccess(SecIdentityCopyCertificate(identity as! SecIdentity, &certificate))
    guard let certificate = certificate else {
        throw BadIdentityError(description: "Identity does not have a certificate")
    }
    var commonName: CFString? = nil
    try checkSuccess(SecCertificateCopyCommonName(certificate, &commonName))
    guard let commonName = commonName else {
        throw BadIdentityError(description: "Identity certificate has no common name")
    }
    return commonName as String
}

private func createAllowedAccess() throws -> SecAccess {
    var newAccess: SecAccess? = nil
    try checkSuccess(SecAccessCreate("Signing identity" as CFString, nil, &newAccess))
    let access = newAccess!
    
    if let aclList = SecAccessCopyMatchingACLList(access, kSecACLAuthorizationSign) as Array? {
        for acl in aclList {
            var applicationList: CFArray? = nil
            var description: CFString? = nil
            var promptSelector = SecKeychainPromptSelector()
            try checkSuccess(SecACLCopyContents(acl as! SecACL, &applicationList, &description, &promptSelector))
            promptSelector.remove(.requirePassphase)
            // Ideally, would only allow /usr/bin/codesign.
            // However, SecTrustedApplicationCreateFromPath is deprecated without replacement.
            // Therefore set applicationList to nil, which allows all applications.
            try checkSuccess(SecACLSetContents(acl as! SecACL, nil, description ?? "" as CFString, promptSelector))
        }
    }
    
    return access
}
