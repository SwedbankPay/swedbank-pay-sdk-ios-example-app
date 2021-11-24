import Foundation
import Security
import JOSESwift

struct AppStoreConnectError: Error {
    var description: String
}
extension AppStoreConnectError: LocalizedError {
    var errorDescription: String? {
        description
    }
}

struct AppStoreConnect {
    let keyData: Data
    let keyId: String
    let keyIssuer: String
    
    private let key: SecKey
    
    init(keyData: Data, keyId: String, keyIssuer: String) throws {
        self.keyData = keyData
        self.keyId = keyId
        self.keyIssuer = keyIssuer
        key = try Self.parseKey(keyData: keyData)
    }
}

extension AppStoreConnect {
    func storeKey(privateKeysParentDirectory: URL) throws {
        // altool will search ./private_keys for the key
        let privateKeysDirectory = privateKeysParentDirectory.appendingPathComponent("private_keys", isDirectory: true)
        try FileManager.default.createDirectory(at: privateKeysDirectory, withIntermediateDirectories: true)
        let keyURL = privateKeysDirectory.appendingPathComponent("AuthKey_\(keyId).p8", isDirectory: false)
        try keyData.write(to: keyURL)
    }
}

extension AppStoreConnect {
    func uploadApp(appURL: URL, privateKeysParentDirectory: URL) throws {
        try run(name: "upload", workingDirectory: privateKeysParentDirectory, "/usr/bin/xcrun", [
            "altool",
            "--upload-app",
            "-f", appURL.path,
            "--type", "ios",
            "--apiKey", keyId,
            "--apiIssuer", keyIssuer
        ])
    }
}

extension AppStoreConnect {
    func getLatestVersion(bundleId: String) throws -> Int? {
        let apps: Apps = try request("/v1/apps?filter[bundleId]=\(bundleId)&fields[apps]=")
        guard let appId = apps.data.first?.id else {
            return nil
        }
        let builds: Builds = try request("/v1/builds?limit=1&sort=-version&filter[app]=\(appId)&fields[builds]=version")
        guard let versionString = builds.data.first?.attributes.version else {
            return nil
        }
        guard let version = Int(versionString) else {
            throw AppStoreConnectError(description: "Latest build version is not an integer")
        }
        return version
    }
    
    struct Apps: Decodable {
        struct App: Decodable {
            var id: String
        }
        var data: [App]
    }
    struct Builds: Decodable {
        struct Build: Decodable {
            struct Attributes: Decodable {
                var version: String
            }
            var attributes: Attributes
        }
        var data: [Build]
    }
}

private extension AppStoreConnect {
    static let baseURL = URL(string: "https://api.appstoreconnect.apple.com/")!
    
    func request<T: Decodable>(_ pathAndQuery: String) throws -> T {
        guard let url = URL(string: pathAndQuery, relativeTo: Self.baseURL) else {
            throw AppStoreConnectError(description: "Invalid request")
        }
        var request = URLRequest(url: url)
        let token = try mintToken(for: pathAndQuery)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let data = try perform(request: request)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func mintToken(for pathAndQuery: String) throws -> String {
        let header = try JWSHeader(parameters: [
            "alg": "ES256",
            "kid": keyId,
            "typ": "JWT"
        ])
        guard let signer = Signer(signingAlgorithm: .ES256, key: key) else {
            throw AppStoreConnectError(description: "App Store Connect key is not an ES256 key")
        }
        
        let now = Date().timeIntervalSince1970.rounded()
        let payload = try Payload(JSONEncoder().encode(TokenPayload(
            iss: keyIssuer,
            iat: now,
            exp: now + 120,
            aud: "appstoreconnect-v1",
            scope: [ "GET \(pathAndQuery)" ]
        )))
        
        let jws = try JWS(header: header, payload: payload, signer: signer)
        return jws.compactSerializedString
    }
    
    struct TokenPayload: Encodable {
        var iss: String
        var iat: Double
        var exp: Double
        var aud: String
        var scope: [String]
    }
}

private extension AppStoreConnect {
    static func parseKey(keyData: Data) throws -> SecKey {
        let derData = try convertToDER(keyData: keyData)
        var items: CFArray? = nil
        try checkSuccess(SecItemImport(derData as CFData, nil, nil, nil, [], nil, nil, &items))
        guard let key = (items as Array?)?.first(where: { CFGetTypeID($0) == SecKeyGetTypeID() }) else {
            throw AppStoreConnectError(description: "Could not import App Store Connect key")
        }
        return key as! SecKey
    }
    
    static func convertToDER(keyData: Data) throws -> Data {
        // SecItemImport does not know how to read PKCS#8 EC keys.
        // OpenSSL to the rescue.
        let output = Pipe()
        defer {
            try? output.fileHandleForReading.close()
        }
        
        do {
            let input = Pipe()
            defer {
                try? input.fileHandleForWriting.close()
            }
            
            let openssl = Process()
            openssl.executableURL = URL(fileURLWithPath: "/usr/bin/openssl")
            openssl.arguments = ["pkcs8", "-nocrypt", "-outform", "der"]
            openssl.standardInput = input
            openssl.standardOutput = output
            try openssl.run()
            try input.fileHandleForWriting.write(contentsOf: keyData)
        }
        
        guard let derData = try output.fileHandleForReading.readToEnd() else {
            throw AppStoreConnectError(description: "Could not convert App Store Connect key to DER")
        }
        return derData
    }
}
