let packageName = "TrivAIDependencies"

let modules: [ModuleManifest] = [
    DependencyModuleManifest(name: "TrivAIClient", dependencies: ["TrivAIResponseModel", "EventSource"], resources: ["Resources"], liveDependencies: ["EventSource"]),
]

// #include("Packages/PackageCommon/Package.swift")
// #COMMON CODE
// =================================================================================
// WARNING: Only change COMMON CODE in included file, not in each Package.swift file as it will get overwritten
// swift-tools-version: 6.1
import PackageDescription

let platforms: [SupportedPlatform] = [.iOS(.v18), .macOS(.v15), .tvOS(.v18)]

// PACKAGES
let githubPackages: [GithubPackageManifest] = [
    .init(provider: "pointfreeco", name: "swift-dependencies", modules: ["Dependencies", "DependenciesMacros", "DependenciesTestSupport"], minVersion: "1.9.2"),
    .init(provider: "Recouse", name: "EventSource", modules: ["EventSource"], minVersion: "0.1.4"),
    .init(provider: "pointfreeco", name: "swift-composable-architecture", modules: ["ComposableArchitecture"], minVersion: "1.19.1"),
    .init(provider: "swiftlang", name: "swift-syntax", modules: ["SwiftSyntaxMacros", "SwiftCompilerPlugin"], minVersion: "601.0.1"),
    .init(provider: "pointfreeco", name: "swift-macro-testing", modules: ["MacroTesting"], minVersion: "0.6.2"),
    .init(provider: "bitkey-oss", name: "sharing-firestore", modules: ["SharingFirestore"], minVersion: "0.2.0"),
]

let localPackages: [LocalPackageManifest] = [
    .init(name: "TrivAIModel", modules: ["TrivAIResponseModel"]),
    .init(name: "TrivAIMacros", modules: ["TrivAIMacros"]),
    .init(name: "TrivAIDependencies", modules: ["TrivAIClient"]),
]

let availablePackages: [any PackageManifest] = githubPackages as [any PackageManifest] + localPackages as [any PackageManifest]

// HELPERS
let package = Package(
    name: packageName,
    platforms: platforms,
    products: modules.flatMap(\.products),
    dependencies: modules.requiredGithubPackages + modules.requiredLocalPackages,
    targets: modules.flatMap(\.targets)
)

extension [ModuleManifest] {
    var allCombinedDependencies: Set<String> {
        Set(flatMap(\.allCombinedDependencies))
    }
    
    @MainActor
    var requiredGithubPackages: [Package.Dependency] {
        githubPackages.thatCanProvideSomeOf(allCombinedDependencies).map(\.packageDependency)
    }

    @MainActor
    var requiredLocalPackages: [Package.Dependency] {
        localPackages.thatCanProvideSomeOf(allCombinedDependencies).map(\.packageDependency)
    }
}

// PACKAGE MANIFEST
protocol PackageManifest {
    var name: String { get }
    var modules: [String] { get }
    var packageDependency: Package.Dependency { get }
}

extension String {
    @MainActor
    var targetDependency: Target.Dependency {
        // Look for the module in the packages
        guard let package = availablePackages.first(where: { $0.modules.contains(self) })?.name else {
            // if not found in the packages, assume the module is in the current package and just refer to it by name
            return .init(stringLiteral: self)
        }
        return .product(name: self, package: package)
    }
    
    var process: Resource {
        Resource.process(self)
    }
}

extension Array where Element: PackageManifest {
    func thatCanProvideSomeOf(_ modules: Set<String>) -> [PackageManifest] {
        filter { $0.modules.contains(where: modules.contains) }
    }
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
class ModuleManifest {
    var name: String
    var dependencies: [String] = []
    var testDependencies: [String] = []
    var resources: [String] = []
    
    init(name: String, dependencies: [String] = [], testDependencies: [String] = [], resources: [String] = []) {
        self.name = name
        self.dependencies = dependencies
        self.testDependencies = testDependencies
        self.resources = resources
    }
    
    var testName: String { "\(name)Tests" }
    var allDependencies: [String] { dependencies }
    var allTestDependencies: [String] { testDependencies + [name] }
    var allCombinedDependencies: [String] { allDependencies + allTestDependencies }
    
    var products: [Product] {
        [
            .library(name: name, targets: [name])
        ]
    }
    
    @MainActor
    var targets: [Target] {
        [
            .target(
                name: name,
                dependencies: allDependencies.map(\.targetDependency),
                resources: resources.map(\.process)
            ),
            .testTarget(
                name: testName,
                dependencies: allTestDependencies.map(\.targetDependency)
            ),
        ]
    }
}

class DependencyModuleManifest: ModuleManifest {
    var liveDependencies: [String] = []
        
    init(name: String, dependencies: [String] = [], testDependencies: [String] = [], resources: [String] = [], liveDependencies: [String] = []) {
        super.init(name: name, dependencies: dependencies, testDependencies: testDependencies, resources: resources)
        self.liveDependencies = liveDependencies
    }
    
    var liveName: String { "\(name)Live" }
    var allLiveDependencies: [String] { liveDependencies + ["Dependencies", name] }

    override var allDependencies: [String] { super.allDependencies + ["Dependencies", "DependenciesMacros"] }
    override var allTestDependencies: [String] { super.allTestDependencies + ["DependenciesTestSupport"] }
    override var allCombinedDependencies: [String] { super.allCombinedDependencies + liveDependencies }

    override var products: [Product] {
        super.products +
        [
           .library(name: liveName, targets: [liveName]),
       ]
    }
    
    @MainActor
    override var targets: [Target] {
        super.targets +
        [
            .target(
                name: liveName,
                dependencies: allLiveDependencies.map(\.targetDependency)
            )
        ]
    }
}

class ModelModuleManifest: ModuleManifest {}

class FeatureModuleManifest: ModuleManifest {
    override var allDependencies: [String] { super.allDependencies + ["ComposableArchitecture"] }
}

// MACRO
import CompilerPluginSupport    // needed for macro support

class MacroModuleManifest: ModuleManifest {
    var macroClientName: String { "\(name)Client" }
    var macroImplementationName: String { "\(name)Macros" }
    
    override var allDependencies: [String] { super.allDependencies + ["SwiftSyntaxMacros", "SwiftCompilerPlugin"] }
    override var allTestDependencies: [String] { super.allTestDependencies + [macroImplementationName, "MacroTesting"] }
    
    override var products: [Product] {
        super.products +
        [
            .executable(name: macroClientName, targets: [macroClientName]),
        ]
    }
    
    @MainActor
    override var targets: [Target] {
        [
            // Macro implementation and its dependencies
            .macro(
                name: macroImplementationName,
                dependencies: allDependencies.map(\.targetDependency)
            ),
            
            // Library that exposes the macro and its features as part of its API which is used in client programs
            .target(name: name, dependencies: [macroImplementationName].map(\.targetDependency)),
            
            // A (optional) client of the library, which is able to use the macro in its own code.
            .executableTarget(name: macroClientName, dependencies: [name].map(\.targetDependency)),

            // A test target used to test the macro implementation.
            .testTarget(
                name: testName,
                dependencies: allTestDependencies.map(\.targetDependency)
            ),
        ]
    }
}
