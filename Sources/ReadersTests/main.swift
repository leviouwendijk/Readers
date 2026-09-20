import Foundation
import Position
import Readers

enum RegressionFailure: Error {
    case assertion(String)
}

func expect(
    _ condition: @autoclosure () -> Bool,
    _ message: String
) throws {
    guard condition() else {
        throw RegressionFailure.assertion(
            message
        )
    }
}

func lineReadResultMaterializesRangesInMemory() throws {
    let file = URL(
        fileURLWithPath: "/tmp/readers.swift"
    )
    let result = LineReadResult(
        url: file,
        lines: [
            "one",
            "two",
            "three",
            "four",
        ],
        encodingUsed: nil,
        byteCount: 18,
        existed: true
    )
    let middle = try LineRange(start: 2, end: 3)
    let first = try LineRange(start: 1, end: 1)
    let last = try LineRange(start: 4, end: 4)

    let slice = result.slice(
        middle
    )

    try expect(
        slice?.file == file,
        "slice preserves file"
    )
    try expect(
        slice?.startLine == 2,
        "slice preserves requested start"
    )
    try expect(
        slice?.lines == [
            "two",
            "three",
        ],
        "slice materializes in-memory lines"
    )

    let slices = result.slices(
        [
            first,
            last,
        ]
    )

    try expect(
        slices.count == 2,
        "multiple ranges materialize independently"
    )
    try expect(
        slices[0].lines == ["one"],
        "first range contents"
    )
    try expect(
        slices[1].lines == ["four"],
        "last range contents"
    )
}

func dataFileReaderUsesIOSystemSource() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent(
            "readers-system-source-\(UUID().uuidString)",
            isDirectory: true
        )
    let file = root.appendingPathComponent(
        "payload.bin",
        isDirectory: false
    )

    try FileManager.default.createDirectory(
        at: root,
        withIntermediateDirectories: true
    )
    defer {
        try? FileManager.default.removeItem(
            at: root
        )
    }

    let payload = Data(
        (0..<(128 * 1024)).map {
            UInt8(
                truncatingIfNeeded: $0
            )
        }
    )

    try payload.write(
        to: file
    )

    let uncached = try DataFileReader(
        file
    ).read()

    try expect(
        uncached.data == payload,
        "default uncached DataFileReader preserves payload"
    )
    try expect(
        uncached.byteCount == payload.count,
        "default uncached DataFileReader preserves byte count"
    )

    let systemCached = try DataFileReader(
        file
    ).read(
        options: .init(
            cachePolicy: .system
        )
    )

    try expect(
        systemCached.data == payload,
        "system-cache DataFileReader preserves payload"
    )
    guard
        let systemSnapshot = systemCached.fileSnapshot,
        let uncachedSnapshot = uncached.fileSnapshot
    else {
        throw RegressionFailure.assertion(
            "existing DataFileReader result must carry a file snapshot"
        )
    }

    try expect(
        systemSnapshot.contentFingerprint
            == uncachedSnapshot.contentFingerprint,
        "IO-backed cache policies preserve fingerprint"
    )
}

try lineReadResultMaterializesRangesInMemory()
try dataFileReaderUsesIOSystemSource()
print("ReadersTests: passed")
