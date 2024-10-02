import Foundation
import Security

private let wwdrCertificateURL = URL(string: "https://www.apple.com/certificateauthority/AppleWWDRCAG3.cer")!

func deployNewVersion(
    projectDirectory: URL,
    scheme: String,
    bundleId: String,
    entitlements: String,
    profileData: Data,
    identityData: Data,
    identityPassword: String,
    appStoreConnectKey: Data,
    appStoreConnectKeyId: String,
    appStoreConnectKeyIssuer: String,
    buildSettings: [String]
) throws {
    try withTemporaryDirectory { tempDir in
        // Gather all the info and put files in their places
        let wwdrCertificate = try WWDRCertificate(url: wwdrCertificateURL)
        
        let appStoreConnect = try AppStoreConnect(keyData: appStoreConnectKey, keyId: appStoreConnectKeyId, keyIssuer: appStoreConnectKeyIssuer)
        try appStoreConnect.storeKey(privateKeysParentDirectory: tempDir)
        
        //version handling can be done automatically by apple, but of some reason does not work
        let latestVersion = try appStoreConnect.getLatestVersion(bundleId: bundleId) ?? 0
        let nextVersion = latestVersion + 1
        
        let profile = try ProvisioningProfile(data: profileData)
        
        let exportOptionsPlistURL = tempDir.appendingPathComponent("ExportOptions.plist", isDirectory: false)
        try createExportOptionsPlist(at: exportOptionsPlistURL, bundleId: bundleId, profileUUID: profile.uuid)
        
        try withKeychain(at: tempDir.appendingPathComponent("signing_keychain", isDirectory: false)) { keychain in
            try wwdrCertificate.import(to: keychain)
            let identityName = try importIdentity(keychain: keychain, data: identityData, password: identityPassword)
            try profile.store()
                        
            let archiveURL = tempDir.appendingPathComponent("Archive.xcarchive", isDirectory: false)
            
            try archiveUnsigned(projectDirectory: projectDirectory, archiveURL: archiveURL, scheme: scheme, version: nextVersion)
            try codeSignBundle(projectDirectory: projectDirectory, archiveURL: archiveURL, identityName: identityName, entitlements: entitlements, appBuildName: "Example-app")
            
            let exportDirectory = tempDir.appendingPathComponent("export", isDirectory: true)
            try exportArchive(projectDirectory: projectDirectory, archiveURL: archiveURL, exportDirectory: exportDirectory, exportOptionsPlistURL: exportOptionsPlistURL)
            try appStoreConnect.uploadApp(appURL: exportDirectory.appendingPathComponent("\(scheme).ipa", isDirectory: false), privateKeysParentDirectory: tempDir)
        }
    }
}
