import Foundation
import Security

do {
    try deployNewVersion(
        projectDirectory: URL(fileURLWithPath: env("GITHUB_WORKSPACE")),
        scheme: "Example-app",
        bundleId: "com.swedbank.swedbank-pay-testapp-prod",
        profileData: envBase64("XCODE_PROVISIONING_PROFILE"),
        identityData: envBase64("XCODE_SIGNING_CERT"),
        identityPassword: env("XCODE_SIGNING_CERT_PASSWORD"),
        appStoreConnectKey: envBase64("APPLE_APP_STORE_CONNECT_KEY"),
        appStoreConnectKeyId: env("APPLE_APP_STORE_CONNECT_KEY_ID"),
        appStoreConnectKeyIssuer: env("APPLE_APP_STORE_CONNECT_KEY_ISSUER_ID"),
        buildSettings: [
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS=PROD_DEMO",
            "SWEDBANKPAY_SDK_CALLBACK_SCHEME=swedbankprodtest"
        ]
    )
} catch {
    print("Deploy failed")
    print(error.localizedDescription)
    exit(EXIT_FAILURE)
}
