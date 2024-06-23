import Entities
import Observation

@MainActor
public protocol FolderStoreProtocol: AnyObject {
    var folders: [Folder] { get }
    var yearMonthSections: [SectionBox<YearMonth, Folder>] { get }
}

extension FolderStoreProtocol {
    public var yearMonthSections: [SectionBox<YearMonth, Folder>] {
        let sectionDct: [YearMonth: [Folder]] = folders
            .lazy
            .reduce(into: [YearMonth: [Folder]].init()) { sections, folder in
                let yearMonth = YearMonth(date: folder.editedAt)
                sections[yearMonth, default: []].append(folder)
            }
        return sectionDct
            .keys
            .lazy
            .sorted { $0.id > $1.id }
            .compactMap { yearMonth in
                let folders = sectionDct[yearMonth]?.sorted { $0.editedAt > $1.editedAt }
                guard let folders else { return nil }
                return SectionBox(header: yearMonth, items: folders)
            }
    }
}

@Observable
public final class DummyFolderStore: FolderStoreProtocol {
    public init() {}
    public var folders: [Folder] = (1...20).map { Folder.dummy($0) }
}
