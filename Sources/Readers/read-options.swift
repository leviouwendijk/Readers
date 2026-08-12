import IO

public enum MissingFilePolicy: Sendable, Hashable, Codable {
    case throwError
    case returnEmpty
}

public enum NewlineNormalization: Sendable, Hashable, Codable {
    case preserve
    case unix
}

public struct TextReadOptions: Sendable, Hashable, Codable {
    public var decoding: TextDecodingStrategy
    public var missingFilePolicy: MissingFilePolicy
    public var newlineNormalization: NewlineNormalization
    public var cachePolicy: FileReadCachePolicy

    public init(
        decoding: TextDecodingStrategy = .commonTextFallbacks,
        missingFilePolicy: MissingFilePolicy = .throwError,
        newlineNormalization: NewlineNormalization = .preserve,
        cachePolicy: FileReadCachePolicy = .uncached
    ) {
        self.decoding = decoding
        self.missingFilePolicy = missingFilePolicy
        self.newlineNormalization = newlineNormalization
        self.cachePolicy = cachePolicy
    }

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        decoding = try container.decode(
            TextDecodingStrategy.self,
            forKey: .decoding
        )

        missingFilePolicy = try container.decode(
            MissingFilePolicy.self,
            forKey: .missingFilePolicy
        )

        newlineNormalization = try container.decode(
            NewlineNormalization.self,
            forKey: .newlineNormalization
        )

        cachePolicy = try container.decodeIfPresent(
            FileReadCachePolicy.self,
            forKey: .cachePolicy
        ) ?? .uncached
    }

    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(
            decoding,
            forKey: .decoding
        )

        try container.encode(
            missingFilePolicy,
            forKey: .missingFilePolicy
        )

        try container.encode(
            newlineNormalization,
            forKey: .newlineNormalization
        )

        try container.encode(
            cachePolicy,
            forKey: .cachePolicy
        )
    }

    public static let `default` = Self()

    private enum CodingKeys: String, CodingKey {
        case decoding
        case missingFilePolicy
        case newlineNormalization
        case cachePolicy
    }
}

public struct LineReadOptions: Sendable, Hashable, Codable {
    public var text: TextReadOptions

    public init(
        text: TextReadOptions = .init(
            decoding: .commonTextFallbacks,
            missingFilePolicy: .throwError,
            newlineNormalization: .unix
        )
    ) {
        self.text = text
    }

    public static let `default` = Self()
}

public struct DataReadOptions: Sendable, Hashable, Codable {
    public var missingFilePolicy: MissingFilePolicy
    public var cachePolicy: FileReadCachePolicy

    public init(
        missingFilePolicy: MissingFilePolicy = .throwError,
        cachePolicy: FileReadCachePolicy = .uncached
    ) {
        self.missingFilePolicy = missingFilePolicy
        self.cachePolicy = cachePolicy
    }

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        missingFilePolicy = try container.decode(
            MissingFilePolicy.self,
            forKey: .missingFilePolicy
        )

        cachePolicy = try container.decodeIfPresent(
            FileReadCachePolicy.self,
            forKey: .cachePolicy
        ) ?? .uncached
    }

    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(
            missingFilePolicy,
            forKey: .missingFilePolicy
        )

        try container.encode(
            cachePolicy,
            forKey: .cachePolicy
        )
    }

    public static let `default` = Self()

    private enum CodingKeys: String, CodingKey {
        case missingFilePolicy
        case cachePolicy
    }
}
