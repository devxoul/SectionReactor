//
//  AppDelegate.swift
//  ArticleFeed
//
//  Created by Suyeol Jeon on 01/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit

import CGFloatLiteral
import ManualLayout
import RxCocoa
import RxSwift
import RxViewController
import SnapKit
import SwiftyColor
import Then

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var dependency: AppDependency!
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    self.dependency = self.dependency ?? AppDependency.resolve()

    self.dependency.window.frame = UIScreen.main.bounds
    self.dependency.window.backgroundColor = .white
    self.dependency.window.makeKeyAndVisible()
    self.dependency.window.rootViewController = self.dependency.rootViewController

    self.window = self.dependency.window
    return true
  }
}
