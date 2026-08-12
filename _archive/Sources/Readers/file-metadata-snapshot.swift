import Foundation

public struct FileMetadataSnapshot: Sendable, Hashable, Codable {
    public let url: URL
    public let existed: Bool
    public let byteCount: Int?
    public let modifiedAt: Date?
    public let identity: FileIdentity?

    public init(
        url: URL,
        existed: Bool,
        byteCount: Int?,
        modifiedAt: Date?,
        identity: FileIdentity?
    ) {
        self.url = url.standardizedFileURL
        self.existed = existed
        self.byteCount = byteCount
        self.modifiedAt = modifiedAt
        self.identity = identity
    }
}
