import Foundation

public enum TextReadError: Error, Sendable, LocalizedError, Hashable {
    case fileNotFound(URL)
    case undecodable(URL, attemptedEncodingNames: [String])
    case io(URL, message: String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "File not found: \(url.path)"

        case .undecodable(let url, let attemptedEncodingNames):
            let joined = attemptedEncodingNames.joined(separator: ", ")
            return "Could not decode file at \(url.path). Attempted encodings: \(joined)"

        case .io(let url, let message):
            return "I/O error while reading \(url.path): \(message)"
        }
    }
}

public enum DataReadError: Error, Sendable, LocalizedError, Hashable {
    case fileNotFound(URL)
    case io(URL, message: String)

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "File not found: \(url.path)"

        case .io(let url, let message):
            return "I/O error while reading \(url.path): \(message)"
        }
    }
}
