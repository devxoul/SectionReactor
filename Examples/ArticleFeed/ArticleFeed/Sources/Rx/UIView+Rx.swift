//
//  UIView+Rx.swift
//  ArticleFeed
//
//  Created by Suyeol Jeon on 01/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: UIView {
  var setNeedsLayout: UIBindingObserver<Base, Void> {
    return UIBindingObserver(UIElement: self.base) { view, _ in
      view.setNeedsLayout()
    }
  }
}
