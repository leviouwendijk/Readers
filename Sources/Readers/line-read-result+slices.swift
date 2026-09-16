import Position

public extension LineReadResult {
    func slice(
        _ range: LineRange
    ) -> FileLineSlice? {
        FileLineSlice(
            file: url,
            lines: lines,
            range: range
        )
    }

    func slices(
        _ ranges: [LineRange]
    ) -> [FileLineSlice] {
        ranges.compactMap { range in
            slice(
                range
            )
        }
    }
}
