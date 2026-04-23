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
        let fileManager = FileManager.default
        let exists = fileManager.fileExists(
            atPath: url.path
        )

        guard exists else {
            switch options.missingFilePolicy {
            case .throwError:
                throw TextReadError.fileNotFound(url)

            case .returnEmpty:
                return .init(
                    url: url,
                    text: "",
                    encodingUsed: nil,
                    byteCount: 0,
                    existed: false
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
            throw TextReadError.io(
                url,
                message: error.localizedDescription
            )
        }

        let attempted = options.decoding.attemptedEncodings

        for encoding in attempted {
            if let decoded = String(
                data: data,
                encoding: encoding.foundation
            ) {
                return .init(
                    url: url,
                    text: normalized(
                        decoded,
                        using: options.newlineNormalization
                    ),
                    encodingUsed: encoding,
                    byteCount: data.count,
                    existed: true
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
