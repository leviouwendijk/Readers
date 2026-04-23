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

    public init(
        decoding: TextDecodingStrategy = .commonTextFallbacks,
        missingFilePolicy: MissingFilePolicy = .throwError,
        newlineNormalization: NewlineNormalization = .preserve
    ) {
        self.decoding = decoding
        self.missingFilePolicy = missingFilePolicy
        self.newlineNormalization = newlineNormalization
    }

    public static let `default` = Self()
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

    public init(
        missingFilePolicy: MissingFilePolicy = .throwError
    ) {
        self.missingFilePolicy = missingFilePolicy
    }

    public static let `default` = Self()
}
