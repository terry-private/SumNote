enum Digit: Int, CaseIterable, CustomStringConvertible {
    case zero, one, two, three, four, five, six, seven, eight, nine

    public var description: String {
        "\(rawValue)"
    }
}
