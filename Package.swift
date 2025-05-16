// swift-tools-version: 6.1
import PackageDescription

let packageName = "TrivAIDependencies"

let packages: [any PackageManifest] =
    [
        GithubPackageManifest.pointFreeDependencies,
        GithubPackageManifest.eventSource,
        LocalPackageManifest(name: "TrivAIModel", modules: ["TrivAIResponseModel"]),
    ]

let modules: [any ModuleManifest] =
    [
        DependencyModuleManifest(name: "TrivAIClient", dependencies: ["TrivAIResponseModel", "EventSource"], liveDependencies: ["EventSource"], resources: ["Resources"]),
    ]


// #include("Packages/PackageCommon/Package.swift")
// #COMMON CODE
// WARNING: Only change COMMON CODE in included file, not in each Package.swift file as it will get overwritten
let platforms: [SupportedPlatform] = [.iOS(.v18), .macOS(.v15), .tvOS(.v18)]

// PACKAGES
extension GithubPackageManifest {
    static var pointFreeDependencies: Self {
        .init(provider: "pointfreeco", name: "swift-dependencies", modules: ["Dependencies", "DependenciesMacros", "DependenciesTestSupport"], minVersion: "1.9.2")
    }
    static var eventSource: Self {
        .init(provider: "Recouse", name: "EventSource", modules: ["EventSource"], minVersion: "0.1.4")
    }
    static var composableArchitecture: Self {
        .init(provider: "pointfreeco", name: "swift-composable-architecture", modules: ["ComposableArchitecture"], minVersion: "1.19.1")
    }
}

// HELPERS
let package = Package(
    name: packageName,
    platforms: platforms,
    products: modules.flatMap(\.products),
    dependencies: packages.map(\.packageDependency),
    targets: modules.flatMap(\.targets),
)

// PACKAGE MANIFEST
protocol PackageManifest {
    var name: String { get }
    var modules: [String] { get }
    var packageDependency: Package.Dependency { get }
}

@MainActor
func targetDependency(_ moduleName: String) -> Target.Dependency {
    // Look for the module in the packages
    guard let package = packages.first(where: { $0.modules.contains(moduleName) })?.name else {
        // if not found in the packages, assume the module is in the current package and just refer to it by name
        return .init(stringLiteral: moduleName)
    }
    return .product(name: moduleName, package: package)
}

struct GithubPackageManifest: PackageManifest {
    let provider: String
    let name: String
    let modules: [String]
    let minVersion: Version

    var packageDependency: Package.Dependency {
        .package(url: "https://github.com/\(provider)/\(name).git", from: minVersion)
    }
}

struct LocalPackageManifest: PackageManifest {
    let name: String
    let modules: [String]
    
    var packageDependency: Package.Dependency {
        .package(path: "../\(name)")
    }
}

// MODULE MANIFEST
protocol ModuleManifest {
    var name: String { get }
    var dependencies: [String] { get }
    var resources: [String] { get }
    var products: [Product] { get }
    @MainActor var targets: [Target] { get }
}

struct DependencyModuleManifest: ModuleManifest {
    var name: String
    var dependencies: [String] = []
    var liveDependencies: [String] = []
    var testDependencies: [String] = []
    var resources: [String] = []
    
    var liveName: String { "\(name)Live" }

    var products: [Product] {
        [
           .library(name: name, targets: [name]),
           .library(name: liveName, targets: [liveName])
       ]
    }
    
    @MainActor
    var targets: [Target] {
        [
            .target(
                name: name,
                dependencies: (dependencies + ["Dependencies", "DependenciesMacros"]).compactMap { targetDependency($0) },
                resources: resources.map { .process($0) }
            ),
            .target(
                name: liveName,
                dependencies: (liveDependencies + ["Dependencies", name]).compactMap { targetDependency($0) }
            ),
            .testTarget(
                name: "\(name)Tests",
                dependencies: (testDependencies + ["DependenciesTestSupport", name]).compactMap { targetDependency($0) }
            )
        ]
    }
}

struct ModelModuleManifest: ModuleManifest {
    var name: String
    var dependencies: [String] = []
    var resources: [String] = []

    var products: [Product] {
        [
           .library(name: name, targets: [name]),
       ]
    }
    
    @MainActor
    var targets: [Target] {
        [
            .target(
                name: name,
                dependencies: dependencies.compactMap { targetDependency($0) },
                resources: resources.map { .process($0) }
            )
        ]
    }
}

struct FeatureModuleManifest: ModuleManifest {
    var name: String
    var dependencies: [String] = []
    var resources: [String] = []

    var products: [Product] {
        [
           .library(name: name, targets: [name]),
       ]
    }
    
    @MainActor
    var targets: [Target] {
        [
            .target(
                name: name,
                dependencies: (dependencies + ["ComposableArchitecture"]).compactMap { targetDependency($0) }
            )
        ]
    }
}
