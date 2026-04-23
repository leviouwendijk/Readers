import Foundation
import Position
import FileTypes

public struct TextReadResult: Sendable, Hashable, Codable {
    public let url: URL
    public let text: String
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool

    public init(
        url: URL,
        text: String,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool
    ) {
        self.url = url
        self.text = text
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
    }

    public var isEmpty: Bool {
        text.isEmpty
    }
}

public struct LineReadResult: Sendable, Hashable, Codable {
    public let url: URL
    public let lines: [String]
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool

    public init(
        url: URL,
        lines: [String],
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool
    ) {
        self.url = url
        self.lines = lines
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
    }

    public var lineCount: Int {
        lines.count
    }

    public var text: String {
        guard !lines.isEmpty else {
            return ""
        }

        return lines.joined(separator: "\n")
    }

    public var lineRange: LineRange? {
        guard !lines.isEmpty else {
            return nil
        }

        return try? LineRange(
            start: 1,
            end: lines.count
        )
    }
}

public struct LineSliceReadResult: Sendable, Hashable, Codable {
    public let url: URL
    public let selectedLines: [String]
    public let selectedLineRange: LineRange?
    public let totalLineCount: Int
    public let truncated: Bool
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool

    public init(
        url: URL,
        selectedLines: [String],
        selectedLineRange: LineRange?,
        totalLineCount: Int,
        truncated: Bool,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool
    ) {
        self.url = url
        self.selectedLines = selectedLines
        self.selectedLineRange = selectedLineRange
        self.totalLineCount = totalLineCount
        self.truncated = truncated
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
    }

    public var lineCount: Int {
        selectedLines.count
    }

    public var text: String {
        guard !selectedLines.isEmpty else {
            return ""
        }

        return selectedLines.joined(separator: "\n")
    }
}

public struct DataReadResult: Sendable, Hashable {
    public let url: URL
    public let data: Data
    public let fileType: AnyFileType?
    public let byteCount: Int
    public let existed: Bool

    public init(
        url: URL,
        data: Data,
        fileType: AnyFileType?,
        byteCount: Int,
        existed: Bool
    ) {
        self.url = url
        self.data = data
        self.fileType = fileType
        self.byteCount = byteCount
        self.existed = existed
    }

    public var isEmpty: Bool {
        data.isEmpty
    }

    public var base64: String {
        data.base64EncodedString()
    }
}

public struct Base64ReadResult: Sendable, Hashable, Codable {
    public let url: URL
    public let base64: String
    public let fileType: AnyFileType?
    public let mediaType: String?
    public let byteCount: Int
    public let existed: Bool

    public init(
        url: URL,
        base64: String,
        fileType: AnyFileType?,
        mediaType: String?,
        byteCount: Int,
        existed: Bool
    ) {
        self.url = url
        self.base64 = base64
        self.fileType = fileType
        self.mediaType = mediaType
        self.byteCount = byteCount
        self.existed = existed
    }

    public var dataURL: String? {
        guard let mediaType else {
            return nil
        }

        return "data:\(mediaType);base64,\(base64)"
    }
}
