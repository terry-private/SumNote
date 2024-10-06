extension String {
    public func isBlank() -> Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    public func dropLast0() -> String {
        var str = self
        while str.hasSuffix("0") && str.contains(".") {
            str = String(str.dropLast())
        }
        if str.hasSuffix(".") {
            str = String(str.dropLast())
        }
        return str
    }
    public func indent(_ indent: Int, spaces: Int = 2) -> String {
        String.indent(indent, spaces: spaces) + self
    }
    public static func indent(_ indent: Int, spaces: Int = 2) -> String {
        String(repeating: " ", count: indent * spaces)
    }
}
