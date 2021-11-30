import Foundation

struct AbnormalTerminationError: Error {
    var processName: String
}
extension AbnormalTerminationError: LocalizedError {
    var errorDescription: String? {
        "\(processName) terminated abnormally"
    }
}

func run(name: String, workingDirectory: URL, _ executablePath: String, _ arguments: [String]) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executablePath)
    process.arguments = arguments
    process.currentDirectoryURL = workingDirectory
    try process.run()
    process.waitUntilExit()
    guard process.terminationReason == .exit && process.terminationStatus == 0 else {
        throw AbnormalTerminationError(processName: name)
    }
}
