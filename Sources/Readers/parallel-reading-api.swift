import Foundation
import IO

public struct ParallelReadingAPI: Sendable {
    public init() {}

    public func inspect(
        _ urls: [URL],
        concurrency: IOConcurrency = .automatic
    ) async throws -> [FileMetadataSnapshot] {
        try await IOExecutor(
            concurrency: concurrency
        ).map(
            urls
        ) { url in
            try FileInspector(
                url
            ).inspect()
        }
    }

    public func data(
        _ urls: [URL],
        options: DataReadOptions = .default,
        concurrency: IOConcurrency = .automatic
    ) async throws -> [DataReadResult] {
        try await IOExecutor(
            concurrency: concurrency
        ).map(
            urls
        ) { url in
            try DataFileReader(
                url
            ).read(
                options: options
            )
        }
    }

    public func data(
        inspected metadata: [FileMetadataSnapshot],
        options: DataReadOptions = .default,
        concurrency: IOConcurrency = .automatic
    ) async throws -> [DataReadResult] {
        try await IOExecutor(
            concurrency: concurrency
        ).map(
            metadata
        ) { metadata in
            try DataFileReader(
                metadata.url
            ).read(
                inspected: metadata,
                options: options
            )
        }
    }

    public func text(
        _ urls: [URL],
        options: TextReadOptions = .default,
        concurrency: IOConcurrency = .automatic
    ) async throws -> [TextReadResult] {
        try await IOExecutor(
            concurrency: concurrency
        ).map(
            urls
        ) { url in
            try TextFileReader(
                url
            ).read(
                options: options
            )
        }
    }

    public func text(
        inspected metadata: [FileMetadataSnapshot],
        options: TextReadOptions = .default,
        concurrency: IOConcurrency = .automatic
    ) async throws -> [TextReadResult] {
        try await IOExecutor(
            concurrency: concurrency
        ).map(
            metadata
        ) { metadata in
            try TextFileReader(
                metadata.url
            ).read(
                inspected: metadata,
                options: options
            )
        }
    }

    public func lines(
        _ urls: [URL],
        options: LineReadOptions = .default,
        concurrency: IOConcurrency = .automatic
    ) async throws -> [LineReadResult] {
        try await IOExecutor(
            concurrency: concurrency
        ).map(
            urls
        ) { url in
            try LineReader(
                url
            ).read(
                options: options
            )
        }
    }

    public func lines(
        inspected metadata: [FileMetadataSnapshot],
        options: LineReadOptions = .default,
        concurrency: IOConcurrency = .automatic
    ) async throws -> [LineReadResult] {
        try await IOExecutor(
            concurrency: concurrency
        ).map(
            metadata
        ) { metadata in
            try LineReader(
                metadata.url
            ).read(
                inspected: metadata,
                options: options
            )
        }
    }
}

public extension Readers {
    static var parallel: ParallelReadingAPI {
        .init()
    }
}
