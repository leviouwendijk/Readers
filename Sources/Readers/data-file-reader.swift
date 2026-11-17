import Foundation
import IO
import FileTypes

public struct DataFileReader: Sendable {
    public let url: URL

    public init(
        _ url: URL
    ) {
        self.url = url
    }

    /// `open` + `fstat` + reads + `close`: no separate inspection. The snapshot
    /// is the opened descriptor's, so it describes exactly the bytes read
    /// (symlinks followed); a missing path or dangling link applies
    /// `missingFilePolicy`.
    public func read(
        options: DataReadOptions = .default
    ) throws -> DataReadResult {
        try readOpened(
            expected: nil,
            options: options
        )
    }

    public func read(
        inspected metadata: FileMetadataSnapshot,
        options: DataReadOptions = .default
    ) throws -> DataReadResult {
        guard metadata.url.standardizedFileURL == url.standardizedFileURL else {
            throw DataReadError.io(
                url,
                message: "Inspected metadata URL does not match reader URL: \(metadata.url.path)"
            )
        }

        guard metadata.existed else {
            return try missing(
                metadata: metadata,
                options: options
            )
        }

        // A symlink snapshot (caller inspected without following) is resolved by
        // the open; other non-regular kinds are refused without opening.
        if let kind = metadata.kind,
           kind != .file,
           kind != .symlink
        {
            throw notRegularFile(
                kind
            )
        }

        return try readOpened(
            expected: metadata.kind == .file
                ? metadata.identity
                : nil,
            options: options
        )
    }

    public func readBase64(
        options: DataReadOptions = .default
    ) throws -> Base64ReadResult {
        let result = try read(
            options: options
        )

        return base64Result(
            from: result
        )
    }

    public func readBase64(
        inspected metadata: FileMetadataSnapshot,
        options: DataReadOptions = .default
    ) throws -> Base64ReadResult {
        let result = try read(
            inspected: metadata,
            options: options
        )

        return base64Result(
            from: result
        )
    }
}

private extension DataFileReader {
    /// `expected`: identity of a regular file the caller inspected; a different
    /// opened file means the caller's snapshot describes other bytes.
    func readOpened(
        expected: FileIdentity?,
        options: DataReadOptions
    ) throws -> DataReadResult {
        let read: (data: Data, metadata: FileMetadataSnapshot)

        do {
            read = try systemData(
                cachePolicy: options.cachePolicy
            )
        } catch SystemFileSourceError.open(_, let code)
            where code == ENOENT || code == ENOTDIR
        {
            // Missing, removed since inspection, or a dangling symlink.
            return try missing(
                metadata: .init(
                    url: url,
                    existed: false,
                    byteCount: nil,
                    modifiedAt: nil,
                    identity: nil,
                    kind: nil
                ),
                options: options
            )
        } catch let error as DataReadError {
            throw error
        } catch {
            throw DataReadError.io(
                url,
                message: error.localizedDescription
            )
        }

        if let expected,
           read.metadata.identity != expected
        {
            throw DataReadError.io(
                url,
                message: "File was replaced between inspection and read."
            )
        }

        return .init(
            url: url,
            data: read.data,
            fileType: inferredFileType,
            byteCount: read.data.count,
            existed: true,
            fileSnapshot: .init(
                metadata: read.metadata,
                contentFingerprint: .fingerprint(
                    for: read.data
                )
            )
        )
    }

    func missing(
        metadata: FileMetadataSnapshot,
        options: DataReadOptions
    ) throws -> DataReadResult {
        switch options.missingFilePolicy {
        case .throwError:
            throw DataReadError.fileNotFound(url)

        case .returnEmpty:
            return .init(
                url: url,
                data: Data(),
                fileType: inferredFileType,
                byteCount: 0,
                existed: false,
                fileSnapshot: .init(
                    metadata: metadata,
                    contentFingerprint: nil
                )
            )
        }
    }

    func notRegularFile(
        _ kind: FileKind
    ) -> DataReadError {
        .io(
            url,
            message: "Not a regular file (\(kind))."
        )
    }

    /// `open(O_NONBLOCK)` + `fstat`, then reads: the same syscall count as an
    /// `lstat` before `open`, but the metadata is the opened descriptor's.
    /// `O_NONBLOCK` keeps a FIFO from hanging the open; it is refused by kind
    /// before any read. Regular-file reads are unaffected by the flag.
    func systemData(
        cachePolicy: FileReadCachePolicy
    ) throws -> (data: Data, metadata: FileMetadataSnapshot) {
        let backend = try SystemFileSource(
            path: url.path,
            cachePolicy: cachePolicy,
            openNonblocking: true
        )
        let metadata = try backend.inspect(
            url: url
        )

        guard metadata.kind == .file else {
            throw notRegularFile(
                metadata.kind ?? .other
            )
        }

        var source = Source(
            backend
        )
        var data = Data()

        if let expectedByteCount = metadata.byteCount,
           expectedByteCount > 0
        {
            data.reserveCapacity(
                expectedByteCount
            )
        }

        while true {
            switch try source.prepare() {
            case .bytes:
                let count = source.bufferedByteCount

                 // source.withReadableRegions {
                 //     first,
                 //     second in

                 //     data.append(
                 //         contentsOf: first
                 //     )
                 //     data.append(
                 //         contentsOf: second
                 //     )
                // }

                source.withReadableRegions { first, second in
                    first.withUnsafeBytes { bytes in
                        data.append(contentsOf: bytes)
                    }
                    second.withUnsafeBytes { bytes in
                        data.append(contentsOf: bytes)
                    }
                }

                try source.consume(
                    count
                )

            case .end:
                return (data, metadata)

            case .unavailable:
                throw DataReadError.io(
                    url,
                    message: "Synchronous file source became unavailable."
                )

            case .buffer_full:
                throw DataReadError.io(
                    url,
                    message: "Synchronous file source could not expose readable capacity."
                )
            }
        }
    }

    func base64Result(
        from result: DataReadResult
    ) -> Base64ReadResult {
        .init(
            url: result.url,
            base64: result.base64,
            fileType: result.fileType,
            mediaType: inferredMediaType(
                from: result.fileType
            ),
            byteCount: result.byteCount,
            existed: result.existed,
            fileSnapshot: result.fileSnapshot
        )
    }

    var inferredFileType: AnyFileType? {
        try? AnyFileType(
            filename: url.lastPathComponent
        )
    }

    func inferredMediaType(
        from fileType: AnyFileType?
    ) -> String? {
        guard let fileType else {
            return nil
        }

        switch fileType {
        case .photo(.png):
            return "image/png"

        case .photo(.jpg), .photo(.jpeg):
            return "image/jpeg"

        case .photo(.gif):
            return "image/gif"

        case .photo(.webp):
            return "image/webp"

        case .photo(.svg):
            return "image/svg+xml"

        case .photo(.bmp):
            return "image/bmp"

        case .photo(.ico):
            return "image/x-icon"

        case .photo(.tiff), .photo(.tif):
            return "image/tiff"

        case .photo(.heic):
            return "image/heic"

        case .photo(.heif):
            return "image/heif"

        case .photo(.avif):
            return "image/avif"

        case .audio(.mp3):
            return "audio/mpeg"

        case .audio(.wav):
            return "audio/wav"

        case .audio(.aac):
            return "audio/aac"

        case .audio(.m4a):
            return "audio/mp4"

        case .audio(.flac):
            return "audio/flac"

        case .audio(.ogg):
            return "audio/ogg"

        case .audio(.opus):
            return "audio/opus"

        case .audio(.aiff):
            return "audio/aiff"

        case .video(.mp4), .video(.m4v):
            return "video/mp4"

        case .video(.mov):
            return "video/quicktime"

        case .video(.mkv):
            return "video/x-matroska"

        case .video(.webm):
            return "video/webm"

        case .video(.avi):
            return "video/x-msvideo"

        case .document(.pdf):
            return "application/pdf"

        case .spreadsheet(.csv):
            return "text/csv"

        case .spreadsheet(.tsv):
            return "text/tab-separated-values"

        case .data(.json):
            return "application/json"

        case .data(.geojson):
            return "application/geo+json"

        case .text(.html):
            return "text/html"

        case .text(.xml):
            return "application/xml"

        case .text(.css):
            return "text/css"

        case .text(.md), .text(.txt), .text(.norg):
            return "text/plain"

        default:
            return nil
        }
    }
}
