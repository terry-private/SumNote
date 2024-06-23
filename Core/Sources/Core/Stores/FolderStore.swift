import Foundation
import Entities
import CoreProtocols

@Observable
public final class FolderStore: FolderStoreProtocol {
    public init() {}
    public var folders: [Folder] = (1...20).map { Folder.dummy($0) }
}

