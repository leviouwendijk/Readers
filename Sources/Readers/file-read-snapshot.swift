import Foundation
import IO

public struct FileReadSnapshot: Sendable, Hashable, Codable {
    public let metadata: FileMetadataSnapshot
    public let contentFingerprint: ContentFingerprint?

    public init(
        metadata: FileMetadataSnapshot,
        contentFingerprint: ContentFingerprint?
    ) {
        self.metadata = metadata
        self.contentFingerprint = contentFingerprint
    }

    public var url: URL {
        metadata.url
    }

    public var existed: Bool {
        metadata.existed
    }

    public var byteCount: Int? {
        metadata.byteCount
    }
}
