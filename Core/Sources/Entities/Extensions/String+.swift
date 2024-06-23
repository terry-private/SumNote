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
}
