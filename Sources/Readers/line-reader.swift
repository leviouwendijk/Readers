import Foundation
import IO
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

        return lineResult(
            from: text
        )
    }

    public func read(
        inspected metadata: FileMetadataSnapshot,
        options: LineReadOptions = .default
    ) throws -> LineReadResult {
        let text = try TextFileReader(url).read(
            inspected: metadata,
            options: options.text
        )

        return lineResult(
            from: text
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
        inspected metadata: FileMetadataSnapshot,
        range: LineRange?,
        maxLines: Int? = nil,
        options: LineReadOptions = .default
    ) throws -> LineSliceReadResult {
        try readSlice(
            inspected: metadata,
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

        return sliceResult(
            from: result,
            startLine: startLine,
            endLine: endLine,
            maxLines: maxLines
        )
    }

    public func readSlice(
        inspected metadata: FileMetadataSnapshot,
        startLine: Int? = nil,
        endLine: Int? = nil,
        maxLines: Int? = nil,
        options: LineReadOptions = .default
    ) throws -> LineSliceReadResult {
        let result = try read(
            inspected: metadata,
            options: options
        )

        return sliceResult(
            from: result,
            startLine: startLine,
            endLine: endLine,
            maxLines: maxLines
        )
    }
}

private extension LineReader {
    func sliceResult(
        from result: LineReadResult,
        startLine: Int?,
        endLine: Int?,
        maxLines: Int?
    ) -> LineSliceReadResult {
        result.slice(
            startLine: startLine,
            endLine: endLine,
            maxLines: maxLines
        )
    }

    func lineResult(
        from text: TextReadResult
    ) -> LineReadResult {
        .init(
            url: url,
            text: text.text,
            encodingUsed: text.encodingUsed,
            byteCount: text.byteCount,
            existed: text.existed,
            fileSnapshot: text.fileSnapshot
        )
    }
}
