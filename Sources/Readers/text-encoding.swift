import Foundation

public struct TextEncoding: Sendable, Hashable, Codable {
    public let rawValue: UInt

    public init(
        rawValue: UInt
    ) {
        self.rawValue = rawValue
    }

    public init(
        _ foundation: String.Encoding
    ) {
        self.rawValue = foundation.rawValue
    }

    public var foundation: String.Encoding {
        .init(rawValue: rawValue)
    }

    public var name: String {
        switch foundation {
        case .utf8:
            return "utf8"

        case .utf16:
            return "utf16"

        case .utf32:
            return "utf32"

        case .ascii:
            return "ascii"

        case .isoLatin1:
            return "isoLatin1"

        default:
            return "encoding(\(rawValue))"
        }
    }

    public static let utf8: Self = .init(.utf8)
    public static let utf16: Self = .init(.utf16)
    public static let utf32: Self = .init(.utf32)
    public static let ascii: Self = .init(.ascii)
    public static let isoLatin1: Self = .init(.isoLatin1)
}
