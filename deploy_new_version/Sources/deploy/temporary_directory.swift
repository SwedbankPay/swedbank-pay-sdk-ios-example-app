import Foundation

func withTemporaryDirectory(operation: (URL) throws -> Void) throws {
    let tempDir = FileManager.default.temporaryDirectory
        .appendingPathComponent(ProcessInfo().globallyUniqueString, isDirectory: true)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    defer {
        try? FileManager.default.removeItem(at: tempDir)
    }
    try operation(tempDir)
}
