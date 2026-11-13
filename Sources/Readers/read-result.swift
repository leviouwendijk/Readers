import Foundation
import Position
import FileTypes

public struct TextReadResult: Sendable, Hashable, Codable {
    public let url: URL
    public let text: String
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool
    public let fileSnapshot: FileReadSnapshot?

    public init(
        url: URL,
        text: String,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool,
        fileSnapshot: FileReadSnapshot? = nil
    ) {
        self.url = url
        self.text = text
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
        self.fileSnapshot = fileSnapshot
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
    public let fileSnapshot: FileReadSnapshot?

    public init(
        url: URL,
        lines: [String],
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool,
        fileSnapshot: FileReadSnapshot? = nil
    ) {
        self.url = url
        self.lines = lines
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
        self.fileSnapshot = fileSnapshot
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
    /// Lines of `text`, split exactly as `LineReader` splits a file.
    public init(
        url: URL,
        text: String,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool,
        fileSnapshot: FileReadSnapshot? = nil
    ) {
        self.init(
            url: url,
            lines: text.isEmpty
                ? []
                : text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init),
            encodingUsed: encodingUsed,
            byteCount: byteCount,
            existed: existed,
            fileSnapshot: fileSnapshot
        )
    }

    /// A window of these lines, 1-based and inclusive; `maxLines` truncates.
    public func slice(
        startLine: Int? = nil,
        endLine: Int? = nil,
        maxLines: Int? = nil
    ) -> LineSliceReadResult {
        let totalLineCount = lineCount

        guard totalLineCount > 0 else {
            return .init(
                url: url,
                selectedLines: [],
                selectedLineRange: nil,
                totalLineCount: 0,
                truncated: false,
                encodingUsed: encodingUsed,
                byteCount: byteCount,
                existed: existed,
                fileSnapshot: fileSnapshot
            )
        }

        let requestedStart = max(1, startLine ?? 1)
        let requestedEnd = min(totalLineCount, endLine ?? totalLineCount)

        guard requestedEnd >= requestedStart else {
            return .init(
                url: url,
                selectedLines: [],
                selectedLineRange: nil,
                totalLineCount: totalLineCount,
                truncated: false,
                encodingUsed: encodingUsed,
                byteCount: byteCount,
                existed: existed,
                fileSnapshot: fileSnapshot
            )
        }

        let lowerBound = requestedStart - 1
        var upperBound = requestedEnd
        var truncated = false

        if let maxLines, maxLines >= 0 {
            let limitedUpperBound = min(upperBound, lowerBound + maxLines)
            truncated = limitedUpperBound < upperBound
            upperBound = limitedUpperBound
        }

        let selectedLines = lowerBound < upperBound
            ? Array(lines[lowerBound..<upperBound])
            : []

        return .init(
            url: url,
            selectedLines: selectedLines,
            selectedLineRange: selectedLines.isEmpty
                ? nil
                : try? LineRange(start: lowerBound + 1, end: upperBound),
            totalLineCount: totalLineCount,
            truncated: truncated,
            encodingUsed: encodingUsed,
            byteCount: byteCount,
            existed: existed,
            fileSnapshot: fileSnapshot
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
    public let fileSnapshot: FileReadSnapshot?

    public init(
        url: URL,
        selectedLines: [String],
        selectedLineRange: LineRange?,
        totalLineCount: Int,
        truncated: Bool,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool,
        fileSnapshot: FileReadSnapshot? = nil
    ) {
        self.url = url
        self.selectedLines = selectedLines
        self.selectedLineRange = selectedLineRange
        self.totalLineCount = totalLineCount
        self.truncated = truncated
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
        self.fileSnapshot = fileSnapshot
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
    public let fileSnapshot: FileReadSnapshot?

    public init(
        url: URL,
        data: Data,
        fileType: AnyFileType?,
        byteCount: Int,
        existed: Bool,
        fileSnapshot: FileReadSnapshot? = nil
    ) {
        self.url = url
        self.data = data
        self.fileType = fileType
        self.byteCount = byteCount
        self.existed = existed
        self.fileSnapshot = fileSnapshot
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
    public let fileSnapshot: FileReadSnapshot?

    public init(
        url: URL,
        base64: String,
        fileType: AnyFileType?,
        mediaType: String?,
        byteCount: Int,
        existed: Bool,
        fileSnapshot: FileReadSnapshot? = nil
    ) {
        self.url = url
        self.base64 = base64
        self.fileType = fileType
        self.mediaType = mediaType
        self.byteCount = byteCount
        self.existed = existed
        self.fileSnapshot = fileSnapshot
    }

    public var dataURL: String? {
        guard let mediaType else {
            return nil
        }

        return "data:\(mediaType);base64,\(base64)"
    }
}
