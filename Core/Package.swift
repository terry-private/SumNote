// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS("17.1")
    ],
    products: Module.allCases.map(\.library),
    dependencies: [
        .package(url: "https://github.com/leif-ibsen/BigInt", from: "1.17.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.6"),
        .package(url: "https://github.com/terry-private/swift-id.git", branch: "main")
    ],
    targets: Module.allCases.map(\.target) + TestModule.allCases.map(\.target)
)

// MARK: 外部モジュール
extension Target.Dependency {
    static var orderdCollections: Self = .product(name: "OrderedCollections", package: "swift-collections")
    static var swiftID: Self = .product(name: "SwiftID", package: "swift-id")
    static var bInt: Self = .product(name: "BigInt", package: "BigInt")
}

// MARK: モジュール親ディレクトリ
enum ParentDirectory: String {
    case core = "Core"
    case features = "Features"
}

// MARK: 内部モジュール
enum Module: String, CaseIterable {
    case entities = "Entities"
    case coreProtocols = "CoreProtocols"
    case stores = "Stores"
    case components = "Components"
    case folderList = "FolderListFeature"
    case noteList = "NoteListFeature"
    case note = "NoteFeature"
    case appDependency = "AppDependency"

    var target: Target {
        return switch self {
        case .entities: target(
            dependencies: [
                .bInt,
                .swiftID
            ],
            dependencyModules: []
        )
        // MARK: - Core -
        case .coreProtocols: target(
            dependencies: [],
            dependencyModules: [
                .entities
            ],
            path: .core
        )
        case .stores: target(
            dependencies: [],
            dependencyModules: [
                .entities,
                .coreProtocols
            ],
            path: .core
        )
        // MARK: - Components -
        case .components: target(
            dependencies: [
                .bInt,
            ],
            dependencyModules: []
        )
        // MARK: - Features -
        case .folderList: target(
            dependencies: [],
            dependencyModules: [
                .entities,
                .coreProtocols,
                .components
            ],
            path: .features
        )
        case .noteList: target(
            dependencies: [],
            dependencyModules: [
                .entities,
                .coreProtocols,
                .components
            ],
            path: .features
        )
        case .note: target(
            dependencies: [],
            dependencyModules: [
                .entities,
                .coreProtocols,
                .components
            ],
            path: .features
        )
        // MARK: - AppDependency -
        case .appDependency: target(
            dependencyModules: [
                .entities,
                .coreProtocols,
                .folderList,
                .noteList,
                .note,
                .stores
            ]
        )
        }
    }
}

// MARK: 内部テストモジュール
enum TestModule: String, CaseIterable {
    case coreTests = "CoreTests"
    
    var target: Target {
        return switch self {
        case .coreTests: testTarget(
            dependencyModules: [
                .entities,
                .coreProtocols,
                .folderList,
                .noteList,
                .note,
                .stores
            ]
        )
        }
    }
}

// MARK: - Extensions
extension Module {
    var library: Product { .library(name: rawValue, targets: [rawValue]) }
    var dependency: Target.Dependency { .init(stringLiteral: rawValue) }
    func target(
        dependencies: [Target.Dependency] = [],
        dependencyModules: [Module] = [],
        path: ParentDirectory? = nil,
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource]? = nil,
        publicHeadersPath: String? = nil,
        packageAccess: Bool = true,
        cSettings: [CSetting]? = nil,
        cxxSettings: [CXXSetting]? = nil,
        swiftSettings: [SwiftSetting]? = [
            .unsafeFlags([
                "-strict-concurrency=complete"
            ])
        ],
        linkerSettings: [LinkerSetting]? = nil,
        plugins: [Target.PluginUsage]? = nil
    ) -> Target {
        .target(
            name: self.rawValue,
            dependencies: dependencyModules.map(\.dependency) + dependencies,
            path: path.map { "./Sources/\($0)/\(rawValue)" },
            exclude: exclude,
            sources: sources,
            resources: resources,
            publicHeadersPath: publicHeadersPath,
            packageAccess: packageAccess,
            cSettings: cSettings,
            cxxSettings: cxxSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings,
            plugins: plugins
        )
    }
}

extension TestModule {
    func testTarget(
        dependencies: [Target.Dependency] = [],
        dependencyModules: [Module] = [],
        path: ParentDirectory? = nil,
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource]? = nil,
        packageAccess: Bool = true,
        cSettings: [CSetting]? = nil,
        cxxSettings: [CXXSetting]? = nil,
        swiftSettings: [SwiftSetting]? = [
            .unsafeFlags([
                "-strict-concurrency=complete"
            ])
        ],
        linkerSettings: [LinkerSetting]? = nil,
        plugins: [Target.PluginUsage]? = nil
    ) -> Target {
        .testTarget(
            name: self.rawValue,
            dependencies: dependencyModules.map(\.dependency) + dependencies,
            path: path.map { "./Sources/\($0)/\(rawValue)" },
            exclude: exclude,
            sources: sources,
            resources: resources,
            packageAccess: packageAccess,
            cSettings: cSettings,
            cxxSettings: cxxSettings,
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings,
            plugins: plugins
        )
    }
}
