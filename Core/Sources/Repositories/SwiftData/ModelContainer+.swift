import Foundation
import SwiftData

extension ModelContainer {
    enum StorageType {
        case inMemory
        case file(fileName: String = #function, shouldDeleteOldFile: Bool = false)

        func modelConfiguration(schema: Schema) throws -> ModelConfiguration {
            switch self {
            case .inMemory:
                // ファイルストレージを使用せずにメモリのみで SwiftData を扱う
                return ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
            case let .file(fileName, shouldDeleteOldFile):
                // ファイルストレージに永続化するための url を指定

                let sqliteURL = URL.documentsDirectory
                    .appending(component: fileName)
                    .appendingPathExtension("sqlite")

                // ファイルストレージの DB を削除するかで
                // これは動作確認をする上で設けています。
                if shouldDeleteOldFile {
                    let fileManager = FileManager.default

                    if fileManager.fileExists(atPath: sqliteURL.path) {
                        try fileManager.removeItem(at: sqliteURL)
                    }
                }
                return ModelConfiguration(
                    schema: schema,
                    url: sqliteURL
                )
            }
        }
    }

    convenience init(
        for types: any PersistentModel.Type...,
        storageType: StorageType = .inMemory
    ) throws {
        // 1. モデル定義のメタタイプで Schema を初期化
        let schema = Schema(types)

        // 2. Schema で ModelConfiguration を初期化
        let modelConfiguration: ModelConfiguration = try storageType.modelConfiguration(schema: schema)

        // 3. ModelConfiguration で ModelContainer を初期化
        try self.init(
            for: schema,
            configurations: [modelConfiguration]
        )
    }
}
