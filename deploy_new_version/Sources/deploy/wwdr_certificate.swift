import Foundation
import Security

struct WWDRCertificate {
    let url: URL
    let data: Data
    
    init(url: URL) throws {
        self.url = url
        data = try get(url: url)
    }
}

extension WWDRCertificate {
    func `import`(to keychain: SecKeychain) throws {
        var inputFormat = SecExternalFormat.formatX509Cert
        try checkSuccess(SecItemImport(
            data as CFData,
            url.lastPathComponent as CFString,
            &inputFormat,
            nil, // itemType
            [], // flags
            nil, // keyParams,
            keychain,
            nil // items
        ))
    }
}
