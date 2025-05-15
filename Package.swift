// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrivAIDependencies",
    platforms: [.iOS(.v18), .macOS(.v15), .tvOS(.v18)],
    products: DependencyManifest.all.flatMap(\.products),
    dependencies: .all,
    targets: DependencyManifest.all.flatMap(\.targets),
)

extension [Package.Dependency] {
    static var all: Self {
        [
            .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2"),
            .package(url: "https://github.com/Recouse/EventSource.git", from: "0.1.4"),
            .package(path: "../TrivAIModel"),
       ]
    }
}

extension DependencyManifest {
    static let all: [Self] = [
        .init(
            name: "TrivAIClient",
            dependencies: [
                .product(name: "TrivAIResponseModel", package: "TrivAIModel"),
                .product(name: "EventSource", package: "EventSource"),
            ],
            liveDependencies: [.product(name: "EventSource", package: "EventSource")],
            resources: [.process("Resources")]
        )
    ]
}

struct DependencyManifest {
    let name: String
    var dependencies: [Target.Dependency] = []
    var liveDependencies: [Target.Dependency] = []
    var testDependencies: [Target.Dependency] = []
    var resources: [Resource] = []
    
    var liveName: String { "\(name)Live" }
    
    var products: [Product] {
        [
           .library(
               name: name,
               targets: [name]
           ),
           .library(
                name: liveName,
                targets: [liveName]
           )
       ]
    }
    
    var targets: [Target] {
        [
            .target(
                name: name,
                dependencies: dependencies + [
                    .product(name: "Dependencies", package: "swift-dependencies"),
                    .product(name: "DependenciesMacros", package: "swift-dependencies"),
                ],
                resources: resources
            ),
            .target(
                name: liveName,
                dependencies: liveDependencies + [
                    .product(name: "Dependencies", package: "swift-dependencies"),
                    .init(stringLiteral: name),
                ]
            ),
            .testTarget(
                name: "\(name)Tests",
                dependencies: testDependencies + [
                    .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
                    .init(stringLiteral: name)
                ]

            )
        ]
    }
}

//
//struct PackageManifest {
//    let provider: String
//    let name: String
//    let components: [String]
//    let minVersion: Version
//
//    var packageDependency: Package.Dependency {
//        .package(url: "https://github.com/\(provider)/\(name).git", from: minVersion)
//    }
//}
//
//extension PackageManifest {
//    static let dependencies = Self(
//        provider: "pointfreeco",
//        name: "swift-dependencies",
//        components: ["Dependencies", "DependenciesMacros", "DependenciesTestSupport"],
//        minVersion: "1.9.2"
//    )
//    static let packages: [Self] = [
//        .dependencies
//    ]
//}
