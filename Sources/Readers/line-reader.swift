import Foundation
import Position

public struct LineReader: Sendable {
    public let url: URL

    public init(
        _ url: URL
    ) {
        self.url = url
    }

    public func read(
        options: LineReadOptions = .default
    ) throws -> LineReadResult {
        let text = try TextFileReader(url).read(
            options: options.text
        )

        return .init(
            url: url,
            lines: splitLines(text.text),
            encodingUsed: text.encodingUsed,
            byteCount: text.byteCount,
            existed: text.existed,
            fileSnapshot: text.fileSnapshot
        )
    }

    public func readSlice(
        range: LineRange?,
        maxLines: Int? = nil,
        options: LineReadOptions = .default
    ) throws -> LineSliceReadResult {
        try readSlice(
            startLine: range?.start,
            endLine: range?.end,
            maxLines: maxLines,
            options: options
        )
    }

    public func readSlice(
        startLine: Int? = nil,
        endLine: Int? = nil,
        maxLines: Int? = nil,
        options: LineReadOptions = .default
    ) throws -> LineSliceReadResult {
        let result = try read(
            options: options
        )

        let totalLineCount = result.lineCount

        guard totalLineCount > 0 else {
            return .init(
                url: url,
                selectedLines: [],
                selectedLineRange: nil,
                totalLineCount: 0,
                truncated: false,
                encodingUsed: result.encodingUsed,
                byteCount: result.byteCount,
                existed: result.existed,
                fileSnapshot: result.fileSnapshot
            )
        }

        let requestedStart = max(1, startLine ?? 1)
        let requestedEnd = min(
            totalLineCount,
            endLine ?? totalLineCount
        )

        guard requestedEnd >= requestedStart else {
            return .init(
                url: url,
                selectedLines: [],
                selectedLineRange: nil,
                totalLineCount: totalLineCount,
                truncated: false,
                encodingUsed: result.encodingUsed,
                byteCount: result.byteCount,
                existed: result.existed,
                fileSnapshot: result.fileSnapshot
            )
        }

        let lowerBound = requestedStart - 1
        var upperBound = requestedEnd

        var truncated = false

        if let maxLines, maxLines >= 0 {
            let limitedUpperBound = min(
                upperBound,
                lowerBound + maxLines
            )

            truncated = limitedUpperBound < upperBound
            upperBound = limitedUpperBound
        }

        let selectedLines: [String]
        if lowerBound < upperBound {
            selectedLines = Array(
                result.lines[lowerBound..<upperBound]
            )
        } else {
            selectedLines = []
        }

        let selectedLineRange: LineRange?
        if selectedLines.isEmpty {
            selectedLineRange = nil
        } else {
            selectedLineRange = try? LineRange(
                start: lowerBound + 1,
                end: upperBound
            )
        }

        return .init(
            url: url,
            selectedLines: selectedLines,
            selectedLineRange: selectedLineRange,
            totalLineCount: totalLineCount,
            truncated: truncated,
            encodingUsed: result.encodingUsed,
            byteCount: result.byteCount,
            existed: result.existed,
            fileSnapshot: result.fileSnapshot
        )
    }
}

private extension LineReader {
    func splitLines(
        _ text: String
    ) -> [String] {
        guard !text.isEmpty else {
            return []
        }

        return text
            .split(
                separator: "\n",
                omittingEmptySubsequences: false
            )
            .map(String.init)
    }
}
