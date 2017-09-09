//
//  ArticleViewController.swift
//  ArticleFeed
//
//  Created by Suyeol Jeon on 07/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit

import ReactorKit
import ReusableKit
import RxDataSources
import RxSwift
import UICollectionViewFlexLayout

final class ArticleViewController: UIViewController, View {

  // MARK: Constants

  fileprivate enum Reusable {
    static let authorCell = ReusableCell<ArticleCardAuthorCell>()
    static let textCell = ReusableCell<ArticleCardTextCell>()
    static let reactionCell = ReusableCell<ArticleCardReactionCell>()
    static let commentCell = ReusableCell<ArticleCardCommentCell>()
    static let sectionBackgroundView = ReusableView<UICollectionReusableView>()
    static let itemBackgroundView = ReusableView<UICollectionReusableView>()
    static let emptyView = ReusableView<UICollectionReusableView>()
  }

  fileprivate enum Metric {
  }

  fileprivate enum Font {
  }

  fileprivate enum Color {
  }


  // MARK: Properties

  var disposeBag = DisposeBag()
  let dataSource = RxCollectionViewSectionedReloadDataSource<ArticleViewSection>()


  // MARK: UI

  let collectionView: UICollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlexLayout()
  ).then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.register(Reusable.authorCell)
    $0.register(Reusable.textCell)
    $0.register(Reusable.reactionCell)
    $0.register(Reusable.commentCell)
    $0.register(Reusable.sectionBackgroundView, kind: UICollectionElementKindSectionBackground)
    $0.register(Reusable.itemBackgroundView, kind: UICollectionElementKindItemBackground)
    $0.register(Reusable.emptyView, kind: "empty")
  }


  // MARK: Initializing

  init(
    reactor: ArticleViewReactor,
    articleCardAuthorCellDependencyFactory: @escaping (Article, UIViewController) -> ArticleCardAuthorCell.Dependency,
    articleCardTextCellDependencyFactory: @escaping (Article, UIViewController) -> ArticleCardTextCell.Dependency,
    articleCardReactionCellDependencyFactory: @escaping (Article, UIViewController) -> ArticleCardReactionCell.Dependency
  ) {
    defer { self.reactor = reactor }
    super.init(nibName: nil, bundle: nil)

    self.title = "Article"

    self.dataSource.configureCell = { [weak self] dataSource, collectionView, indexPath, sectionItem in
      guard let `self` = self else {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "__empty")
        return collectionView.dequeueReusableCell(withReuseIdentifier: "__empty", for: indexPath)
      }

      let articleCardAuthorCellDependency: ArticleCardAuthorCell.Dependency
      let articleCardTextCellDependency: ArticleCardTextCell.Dependency
      let articleCardReactionCellDependency: ArticleCardReactionCell.Dependency

      let section = dataSource[indexPath.section]
      switch section {
      case let .article(sectionReactor):
        let article = sectionReactor.currentState.article
        articleCardAuthorCellDependency = articleCardAuthorCellDependencyFactory(article, self)
        articleCardTextCellDependency = articleCardTextCellDependencyFactory(article, self)
        articleCardReactionCellDependency = articleCardReactionCellDependencyFactory(article, self)
      }

      switch sectionItem {
      case let .author(cellReactor):
        let cell = collectionView.dequeue(Reusable.authorCell, for: indexPath)
        cell.dependency = articleCardAuthorCellDependency
        cell.reactor = cellReactor
        return cell

      case let .text(cellReactor):
        let cell = collectionView.dequeue(Reusable.textCell, for: indexPath)
        cell.dependency = articleCardTextCellDependency
        cell.reactor = cellReactor
        return cell

      case let .reaction(cellReactor):
        let cell = collectionView.dequeue(Reusable.reactionCell, for: indexPath)
        cell.dependency = articleCardReactionCellDependency
        cell.reactor = cellReactor
        return cell

      case let .comment(cellReactor):
        let cell = collectionView.dequeue(Reusable.commentCell, for: indexPath)
        cell.reactor = cellReactor
        return cell
      }
    }

    self.dataSource.supplementaryViewFactory = { dataSource, collectionView, kind, indexPath in
      switch kind {
      case UICollectionElementKindSectionBackground:
        let view = collectionView.dequeue(Reusable.sectionBackgroundView, kind: kind, for: indexPath)
        view.backgroundColor = .white
        return view

      case UICollectionElementKindItemBackground:
        return collectionView.dequeue(Reusable.itemBackgroundView, kind: kind, for: indexPath)

      default:
        fatalError("fuck")
      }
    }
  }

  required convenience init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = 0xEDEDED.color
    self.view.addSubview(self.collectionView)

    self.collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }


  // MARK: Binding

  func bind(reactor: ArticleViewReactor) {
    // State
    reactor.state.map { $0.authorName }
      .distinctUntilChanged()
      .map { $0.components(separatedBy: " ").first ?? $0 }
      .map { "\($0)'s Article" }
      .bind(to: self.rx.title)
      .disposed(by: self.disposeBag)

    reactor.state.map { $0.sections }
      .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)

    // View
    self.collectionView.rx
      .setDelegate(self)
      .disposed(by: self.disposeBag)
  }
}

extension ArticleViewController: UICollectionViewDelegateFlexLayout {
  // section padding
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewFlexLayout,
    paddingForSectionAt section: Int
  ) -> UIEdgeInsets {
    return .init(top: 10, left: 10, bottom: 10, right: 10)
  }

  // section spacing
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewFlexLayout,
    verticalSpacingBetweenSectionAt section: Int,
    and nextSection: Int
  ) -> CGFloat {
    return 10
  }

  // item spacing
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewFlexLayout,
    verticalSpacingBetweenItemAt indexPath: IndexPath,
    and nextIndexPath: IndexPath
  ) -> CGFloat {
    switch (self.dataSource[indexPath], self.dataSource[nextIndexPath]) {
    case (_, .comment): return 15
    case (.author, _): return 10
    case (.text, _): return 10
    case (.reaction, _): return 10
    case (.comment, _): return 10
    }
  }

  // item size
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewFlexLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let maxWidth = collectionViewLayout.maximumWidth(forItemAt: indexPath)
    switch self.dataSource[indexPath] {
    case let .author(cellReactor):
      return Reusable.authorCell.class.size(width: maxWidth, reactor: cellReactor)

    case let .text(cellReactor):
      return Reusable.textCell.class.size(width: maxWidth, reactor: cellReactor)

    case let .reaction(cellReactor):
      return Reusable.reactionCell.class.size(width: maxWidth, reactor: cellReactor)

    case let .comment(cellReactor):
      return Reusable.commentCell.class.size(width: maxWidth, reactor: cellReactor)
    }
  }
}
