import Foundation

public struct TextFileReader: Sendable {
    public let url: URL

    public init(
        _ url: URL
    ) {
        self.url = url
    }

    public func read(
        options: TextReadOptions = .default
    ) throws -> TextReadResult {
        let dataResult: DataReadResult

        do {
            dataResult = try DataFileReader(
                url
            ).read(
                options: .init(
                    missingFilePolicy: options.missingFilePolicy
                )
            )
        } catch let error as DataReadError {
            switch error {
            case .fileNotFound(let url):
                throw TextReadError.fileNotFound(
                    url
                )

            case .io(let url, let message):
                throw TextReadError.io(
                    url,
                    message: message
                )
            }
        }

        guard dataResult.existed else {
            return .init(
                url: url,
                text: "",
                encodingUsed: nil,
                byteCount: 0,
                existed: false,
                fileSnapshot: dataResult.fileSnapshot
            )
        }

        let attempted = options.decoding.attemptedEncodings

        for encoding in attempted {
            if let decoded = String(
                data: dataResult.data,
                encoding: encoding.foundation
            ) {
                return .init(
                    url: url,
                    text: normalized(
                        decoded,
                        using: options.newlineNormalization
                    ),
                    encodingUsed: encoding,
                    byteCount: dataResult.byteCount,
                    existed: true,
                    fileSnapshot: dataResult.fileSnapshot
                )
            }
        }

        throw TextReadError.undecodable(
            url,
            attemptedEncodingNames: attempted.map(\.name)
        )
    }
}

private extension TextFileReader {
    func normalized(
        _ text: String,
        using normalization: NewlineNormalization
    ) -> String {
        switch normalization {
        case .preserve:
            return text

        case .unix:
            return text
                .replacingOccurrences(of: "\r\n", with: "\n")
                .replacingOccurrences(of: "\r", with: "\n")
        }
    }
}
