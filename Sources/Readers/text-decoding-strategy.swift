public enum TextDecodingStrategy: Sendable, Hashable, Codable {
    case exact(TextEncoding)
    case fallback(
        primary: TextEncoding,
        fallbacks: [TextEncoding]
    )

    public static let utf8: Self = .exact(.utf8)

    public static let commonTextFallbacks: Self = .fallback(
        primary: .utf8,
        fallbacks: [
            .utf16,
            .isoLatin1
        ]
    )

    public var attemptedEncodings: [TextEncoding] {
        switch self {
        case .exact(let encoding):
            return [encoding]

        case .fallback(let primary, let fallbacks):
            var out: [TextEncoding] = []
            var seen = Set<TextEncoding>()

            for encoding in [primary] + fallbacks {
                guard seen.insert(encoding).inserted else {
                    continue
                }

                out.append(encoding)
            }

            return out
        }
    }
}
