import Foundation

func archive(
    projectDirectory: URL,
    archiveURL: URL,
    scheme: String,
    version: Int,
    bundleId: String,
    identityName: String,
    provisioningProfile: ProvisioningProfile,
    buildSettings: [String]
) throws {
    try run(name: "archive", workingDirectory: projectDirectory, "/usr/bin/xcodebuild", [
        "-scheme", scheme,
        "-archivePath", archiveURL.path,
        "archive",
        "-destination", "generic/platform=iOS",
        "CURRENT_PROJECT_VERSION=\(version)",
        "PRODUCT_BUNDLE_IDENTIFIER=\(bundleId)",
        "CODE_SIGN_STYLE=Manual",
        "CODE_SIGN_IDENTITY=\(identityName)",
        "PROVISIONING_PROFILE=\(provisioningProfile.uuid)"
    ] + buildSettings)
}

func exportArchive(
    projectDirectory: URL,
    archiveURL: URL,
    exportDirectory: URL,
    exportOptionsPlistURL: URL
) throws {
    try run(name: "export", workingDirectory: projectDirectory, "/usr/bin/xcodebuild", [
        "-exportArchive",
        "-archivePath", archiveURL.path,
        "-exportPath", exportDirectory.path,
        "-exportOptionsPlist", exportOptionsPlistURL.path
    ])
}
