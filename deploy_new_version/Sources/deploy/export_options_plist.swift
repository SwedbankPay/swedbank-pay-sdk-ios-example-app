import Foundation

func createExportOptionsPlist(at url: URL, bundleId: String, profileUUID: String) throws {
    try PropertyListEncoder()
        .encode(ExportOptions(provisioningProfiles: [bundleId: profileUUID]))
        .write(to: url)
}

private struct ExportOptions: Encodable {
    let generateAppStoreInformation = true
    let manageAppVersionAndBuildNumber = true
    let method = "app-store"
    var provisioningProfiles: [String: String]
}
