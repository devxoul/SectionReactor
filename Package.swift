// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "SectionReactor",
  products: [
    .library(name: "SectionReactor", targets: ["SectionReactor"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactorKit/ReactorKit.git", .branch("swift-4.0")),
    .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", .branch("swift4.0")),
    .package(url: "https://github.com/devxoul/RxExpect", .branch("swift-4.0")),
  ],
  targets: [
    .target(name: "SectionReactor", dependencies: ["ReactorKit", "RxDataSources"]),
    .testTarget(name: "SectionReactorTests", dependencies: ["SectionReactor", "RxExpect"])
  ]
)
