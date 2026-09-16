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

try lineReadResultMaterializesRangesInMemory()
print("ReadersTests: passed")
