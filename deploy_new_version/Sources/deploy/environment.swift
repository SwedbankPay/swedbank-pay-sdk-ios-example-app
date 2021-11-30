import Foundation

struct BadEnvironmentError: Error {
    var name: String
    var base64Error: Bool
}
extension BadEnvironmentError: LocalizedError {
    var errorDescription: String? {
        let header = base64Error ? "Base64 error" : "Missing"
        return "\(header): \(name)"
    }
}

func env(_ name: String) throws -> String {
    guard let value = ProcessInfo.processInfo.environment[name] else {
        throw BadEnvironmentError(name: name, base64Error: false)
    }
    return value
}
func envBase64(_ name: String) throws -> Data {
    guard let data = try Data(base64Encoded: env(name)) else {
        throw BadEnvironmentError(name: name, base64Error: true)
    }
    return data
}
