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
        .package(url: "https://github.com/leif-ibsen/BigInt", from: "1.17.0")
    ],
    targets: Module.allCases.map(\.target) + TestModule.allCases.map(\.target)
)

// MARK: 外部モジュール
extension Target.Dependency {
    init(_ module: Module) {
        self = module.dependency
    }
    static var bInt: Self { .product(name: "BigInt", package: "BigInt") }
}

// MARK: モジュール親ディレクトリ
enum ParentDirectory: String {
    case core
    case features
}

// MARK: 内部モジュール
enum Module: String, CaseIterable {
    case entities
    case coreProtocols
    case stores
    case components
    case folderList
    case noteList
    case note
    case appDependency
    case repositories

    var target: Target {
        return switch self {
        case .entities: target(
            dependencies: [
                .bInt
            ]
        )
        // MARK: - Core -
        case .coreProtocols: target(
            dependencies: [
                .init(.entities),
                .init(.repositories)
            ],
            path: .core
        )
        case .stores: target(
            dependencies: [
                .init(.entities),
                .init(.coreProtocols),
                .init(.repositories),
            ],
            path: .core
        )
        // MARK: - Components -
        case .components: target(
            dependencies: [
                .bInt,
            ]
        )
        // MARK: - Features -
        case .folderList: target(
            dependencies: [
                .init(.entities),
                .init(.coreProtocols),
                .init(.components),
                .init(.stores)
            ],
            path: .features
        )
        case .noteList: target(
            dependencies: [
                .init(.entities),
                .init(.coreProtocols),
                .init(.components),
                .init(.stores)
            ],
            path: .features
        )
        case .note: target(
            dependencies: [
                .init(.entities),
                .init(.coreProtocols),
                .init(.components),
                .init(.stores),
            ],
            path: .features
        )
        // MARK: - AppDependency -
        case .appDependency: target(
            dependencies: [
                .init(.entities),
                .init(.coreProtocols),
                .init(.folderList),
                .init(.noteList),
                .init(.note),
                .init(.stores),
            ]
        )
        case .repositories: target(
            dependencies: [
                .init(.entities)
            ]
        )
        }
    }
}

// MARK: 内部テストモジュール
enum TestModule: String, CaseIterable {
    case coreTests
    
    var target: Target {
        return switch self {
        case .coreTests: testTarget(
            dependencies: [
                .init(.entities),
                .init(.coreProtocols),
                .init(.folderList),
                .init(.noteList),
                .init(.note),
                .init(.stores)
            ]
        )
        }
    }
}

// MARK: - Extensions
private extension Module {
    var library: Product { .library(name: name, targets: [name]) }
    var dependency: Target.Dependency { .init(stringLiteral: name) }
    func target(
        dependencies: [Target.Dependency] = [],
        path: ParentDirectory? = nil,
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource]? = nil,
        publicHeadersPath: String? = nil,
        packageAccess: Bool = true,
        cSettings: [CSetting]? = nil,
        cxxSettings: [CXXSetting]? = nil,
        swiftSettings: [SwiftSetting]? = [],
        linkerSettings: [LinkerSetting]? = nil,
        plugins: [Target.PluginUsage]? = nil
    ) -> Target {
        .target(
            name: name,
            dependencies: dependencies,
            path: path.map { "./Sources/\($0.name)/\(name)" },
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

private extension TestModule {
    func testTarget(
        dependencies: [Target.Dependency] = [],
        path: ParentDirectory? = nil,
        exclude: [String] = [],
        sources: [String]? = nil,
        resources: [Resource]? = nil,
        packageAccess: Bool = true,
        cSettings: [CSetting]? = nil,
        cxxSettings: [CXXSetting]? = nil,
        swiftSettings: [SwiftSetting]? = [],
        linkerSettings: [LinkerSetting]? = nil,
        plugins: [Target.PluginUsage]? = nil
    ) -> Target {
        .testTarget(
            name: name,
            dependencies: dependencies,
            path: path.map { "./Sources/\($0.name)/\(name)" },
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

private extension RawRepresentable where Self.RawValue == String {
    var name: String {
        self.rawValue.prefix(1).uppercased() + rawValue.dropFirst()
    }
}
