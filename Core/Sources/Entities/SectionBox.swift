import Foundation
import SwiftID

public protocol SectionHeader: Identifiable, Hashable, Sendable, Equatable {
    var title: String { get }
}

public struct SectionBox<Header: SectionHeader, Item: Identifiable & Hashable & Sendable>: Identifiable, Hashable, Sendable, Equatable {
    public var id: Header.ID { header.id }
    public var header: Header
    public var items: [Item]
    public init(header: Header, items: [Item]) {
        self.header = header
        self.items = items
    }
}
