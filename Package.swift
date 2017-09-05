// swift-tools-version:3.1

import PackageDescription

let package = Package(
  name: "SectionReactor",
  dependencies: [
    .Package(url: "https://github.com/ReactorKit/ReactorKit.git", majorVersion: 0),
    .Package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", majorVersion: 2),
  ]
)
