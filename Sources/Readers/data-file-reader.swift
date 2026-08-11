import Foundation
import FileTypes

public struct DataFileReader: Sendable {
    public let url: URL

    public init(
        _ url: URL
    ) {
        self.url = url
    }

    public func read(
        options: DataReadOptions = .default
    ) throws -> DataReadResult {
        let metadata: FileMetadataSnapshot

        do {
            metadata = try FileInspector(
                url
            ).inspect()
        } catch {
            throw DataReadError.io(
                url,
                message: error.localizedDescription
            )
        }

        guard metadata.existed else {
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

        let data: Data

        do {
            data = try Data(
                contentsOf: url,
                options: [.uncached]
            )
        } catch {
            throw DataReadError.io(
                url,
                message: error.localizedDescription
            )
        }

        return .init(
            url: url,
            data: data,
            fileType: inferredFileType,
            byteCount: data.count,
            existed: true,
            fileSnapshot: .init(
                metadata: metadata,
                contentFingerprint: .fingerprint(
                    for: data
                )
            )
        )
    }

    public func readBase64(
        options: DataReadOptions = .default
    ) throws -> Base64ReadResult {
        let result = try read(
            options: options
        )

        return .init(
            url: result.url,
            base64: result.base64,
            fileType: result.fileType,
            mediaType: inferredMediaType(from: result.fileType),
            byteCount: result.byteCount,
            existed: result.existed,
            fileSnapshot: result.fileSnapshot
        )
    }
}

private extension DataFileReader {
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
