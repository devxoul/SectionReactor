// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "SectionReactor",
  platforms: [
    .iOS(.v8), .tvOS(.v9)
  ],
  products: [
    .library(name: "SectionReactor", targets: ["SectionReactor"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactorKit/ReactorKit.git", .upToNextMajor(from: "1.0.0")),
    .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", .upToNextMajor(from: "3.0.1")),
    .package(url: "https://github.com/devxoul/RxExpect.git", .upToNextMajor(from: "1.0.0")),
  ],
  targets: [
    .target(name: "SectionReactor", dependencies: ["ReactorKit", "RxDataSources"]),
    .testTarget(name: "SectionReactorTests", dependencies: ["SectionReactor", "RxExpect"])
  ]
)
