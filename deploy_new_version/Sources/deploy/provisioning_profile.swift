import Foundation
import Security

struct BadProfileError: Error {
    var description: String
}
extension BadProfileError: LocalizedError {
    var errorDescription: String? {
        description
    }
}

struct ProvisioningProfile {
    let data: Data
    let uuid: String
    
    init(data: Data) throws {
        self.data = data
        self.uuid = try getProfileUUID(profileData: data)
    }
}

extension ProvisioningProfile {
    func store() throws {
        let url = try storageURLForProfile(uuid: uuid)
        try data.write(to: url, options: .atomic)
    }
}

private func getProfileUUID(profileData: Data) throws -> String {
    var newDecoder: CMSDecoder? = nil
    try checkSuccess(CMSDecoderCreate(&newDecoder))
    let decoder = newDecoder!
    
    try profileData.withUnsafeBytes {
        guard let baseAddress = $0.baseAddress else {
            throw BadProfileError(description: "Empty profile data")
        }
        try checkSuccess(CMSDecoderUpdateMessage(decoder, baseAddress, $0.count))
    }
    try checkSuccess(CMSDecoderFinalizeMessage(decoder))
    
    var content: CFData? = nil
    try checkSuccess(CMSDecoderCopyContent(decoder, &content))
    
    guard let content = content else {
        throw BadProfileError(description: "Missing profile content")
    }
    let plist = try PropertyListSerialization.propertyList(from: content as Data, format: nil)
    guard let dict = plist as? NSDictionary else {
        throw BadProfileError(description: "Profile content is not a dictionary")
    }
    guard let uuid = dict["UUID"] as? String else {
        throw BadProfileError(description: "Profile UUID is not a string")
    }
    return uuid
}

private func storageURLForProfile(uuid: String) throws -> URL {
    let libraryDirectory = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let profileDirectory = libraryDirectory
        .appendingPathComponent("MobileDevice", isDirectory: true)
        .appendingPathComponent("Provisioning Profiles", isDirectory: true)
    try FileManager.default.createDirectory(at: profileDirectory, withIntermediateDirectories: true)
    return profileDirectory.appendingPathComponent("\(uuid).mobileprovision", isDirectory: false)
}
