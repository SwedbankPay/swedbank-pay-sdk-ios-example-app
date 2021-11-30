import Foundation
import Security

struct SecurityFrameworkError: Error {
    var osStatus: OSStatus
}
extension SecurityFrameworkError: LocalizedError {
    var errorDescription: String? {
        SecCopyErrorMessageString(osStatus, nil) as String? ?? "OSStatus: \(osStatus)"
    }
}

func checkSuccess(_ osStatus: OSStatus) throws {
    guard osStatus == noErr else {
        throw SecurityFrameworkError(osStatus: osStatus)
    }
}
