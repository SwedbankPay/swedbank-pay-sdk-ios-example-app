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

///We cannot sign any SPM modules like the SDK, so we need to archive the app without signing.
///usr/bin/xcodebuild archive -scheme Example-app -destination generic/platform=iOS -archivePath $archivePath -verbose CODE_SIGNING_REQUIRED=Yes CODE_SIGNING_ALLOWED=No
func archiveUnsigned(
    projectDirectory: URL,
    archiveURL: URL,
    scheme: String
) throws {
    try run(name: "archiveUnsigned", workingDirectory: projectDirectory, "/usr/bin/xcodebuild", [
        "-scheme", scheme,
        "-archivePath", archiveURL.path,
        "archive",
        "-destination", "generic/platform=iOS",
        "-verbose", "CODE_SIGNING_REQUIRED=Yes", "CODE_SIGNING_ALLOWED=No"
    ])
}

///After archiving we can sign the app-bundle only
///codesign -s $CODE_SIGN_IDENTITY $archivePath/Products/Applications/Example-app.app
func codeSignBundle(
    projectDirectory: URL,
    archiveURL: URL,
    identityName: String,
    appBuildName: String    //e.g. Example-app
) throws {
    let path = archiveURL.appendingPathComponent("/Products/Applications/\(appBuildName).app").path
    try run(name: "codeSignBundle", workingDirectory: projectDirectory, "/usr/bin/codesign", [
        "-s", identityName,
        path
    ])
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


