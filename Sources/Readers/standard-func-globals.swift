import Foundation

public enum StandardReading {
    public static func text(
        at url: URL,
        encoding: String.Encoding,
        missingFileReturnsEmpty: Bool = true,
        normalizeNewlines: Bool = false
    ) throws -> String {
        let missingFilePolicy: MissingFilePolicy = missingFileReturnsEmpty
            ? .returnEmpty
            : .throwError

        let newlineNormalization: NewlineNormalization = normalizeNewlines
            ? .unix
            : .preserve

        let result = try TextFileReader(url).read(
            options: .init(
                decoding: .exact(.init(encoding)),
                missingFilePolicy: missingFilePolicy,
                newlineNormalization: newlineNormalization
            )
        )

        return result.text
    }

    public static func data(
        at url: URL,
        missingFileReturnsEmpty: Bool = true
    ) throws -> Data {
        let missingFilePolicy: MissingFilePolicy = missingFileReturnsEmpty
            ? .returnEmpty
            : .throwError

        let result = try DataFileReader(url).read(
            options: .init(
                missingFilePolicy: missingFilePolicy
            )
        )

        return result.data
    }
}
