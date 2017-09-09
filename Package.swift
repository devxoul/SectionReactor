// swift-tools-version:3.1

import Foundation
import PackageDescription

var dependencies: [Package.Dependency] = [
  .Package(url: "https://github.com/ReactorKit/ReactorKit.git", majorVersion: 0),
  .Package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git", majorVersion: 2),
]

let isTest = ProcessInfo.processInfo.environment["TEST"] == "1"
if isTest {
  dependencies.append(
    .Package(url: "https://github.com/devxoul/RxExpect.git", majorVersion: 0)
  )
}

let package = Package(
  name: "SectionReactor",
  dependencies: dependencies
)
