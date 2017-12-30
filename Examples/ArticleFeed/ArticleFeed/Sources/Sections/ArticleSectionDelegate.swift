//
//  ArticleSectionDelegate.swift
//  ArticleFeed
//
//  Created by Suyeol Jeon on 09/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import ReusableKit
import SectionReactor
import UICollectionViewFlexLayout
import URLNavigator

final class ArticleSectionDelegate: SectionDelegateType {
  typealias SectionReactor = ArticleSectionReactor

  fileprivate enum Reusable {
    static let authorCell = ReusableCell<ArticleCardAuthorCell>()
    static let textCell = ReusableCell<ArticleCardTextCell>()
    static let reactionCell = ReusableCell<ArticleCardReactionCell>()
    static let commentCell = ReusableCell<ArticleCardCommentCell>()
    static let sectionBackgroundView = ReusableView<CollectionBorderedBackgroundView>()
    static let itemBackgroundView = ReusableView<CollectionBorderedBackgroundView>()
  }

  private let navigator: NavigatorType
  private let articleViewControllerFactory: (Article) -> ArticleViewController
  private let presentsArticleViewControllerWhenTaps: Bool

  init(
    navigator: NavigatorType,
    articleViewControllerFactory: @escaping (Article) -> ArticleViewController,
    presentsArticleViewControllerWhenTaps: Bool
  ) {
    self.navigator = navigator
    self.articleViewControllerFactory = articleViewControllerFactory
    self.presentsArticleViewControllerWhenTaps = presentsArticleViewControllerWhenTaps
  }

  func registerReusables(to collectionView: UICollectionView) {
    collectionView.register(Reusable.authorCell)
    collectionView.register(Reusable.textCell)
    collectionView.register(Reusable.reactionCell)
    collectionView.register(Reusable.commentCell)
    collectionView.register(Reusable.sectionBackgroundView, kind: UICollectionElementKindSectionBackground)
    collectionView.register(Reusable.itemBackgroundView, kind: UICollectionElementKindItemBackground)
  }

  func cell(
    collectionView: UICollectionView,
    indexPath: IndexPath,
    sectionReactor: SectionReactor,
    sectionItem: SectionItem
  ) -> UICollectionViewCell {
    switch sectionItem {
    case let .author(cellReactor):
      let cell = collectionView.dequeue(Reusable.authorCell, for: indexPath)
      if cell.reactor !== cellReactor {
        cell.reactor = cellReactor
        self.subscribeTapToPresentArticleViewController(cell: cell, sectionReactor: sectionReactor)
      }
      return cell

    case let .text(cellReactor):
      let cell = collectionView.dequeue(Reusable.textCell, for: indexPath)
      if cell.reactor !== cellReactor {
        cell.reactor = cellReactor
        self.subscribeTapToPresentArticleViewController(cell: cell, sectionReactor: sectionReactor)
      }
      return cell

    case let .reaction(cellReactor):
      let cell = collectionView.dequeue(Reusable.reactionCell, for: indexPath)
      if cell.reactor !== cellReactor {
        cell.reactor = cellReactor
        self.subscribeTapToPresentArticleViewController(cell: cell, sectionReactor: sectionReactor)
      }
      return cell

    case let .comment(cellReactor):
      let cell = collectionView.dequeue(Reusable.commentCell, for: indexPath)
      if cell.reactor !== cellReactor {
        cell.reactor = cellReactor
      }
      return cell
    }
  }

  func supplementaryView(
    collectionView: UICollectionView,
    kind: String,
    indexPath: IndexPath,
    sectionReactor: SectionReactor,
    sectionItem: SectionItem
  ) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionBackground:
      let view = collectionView.dequeue(Reusable.sectionBackgroundView, kind: kind, for: indexPath)
      view.backgroundColor = .white
      view.borderedLayer?.borders = [.top, .bottom]
      return view

    case UICollectionElementKindItemBackground:
      switch sectionItem {
      case .comment:
        let view = collectionView.dequeue(Reusable.itemBackgroundView, kind: kind, for: indexPath)
        view.backgroundColor = 0xFAFAFA.color
        if self.isFirstComment(indexPath, in: sectionReactor.currentState.sectionItems) {
          view.borderedLayer?.borders = [.top]
        } else if self.isLast(indexPath, in: collectionView) {
          view.borderedLayer?.borders = [.bottom]
        } else {
          view.borderedLayer?.borders = []
        }
        return view

      default:
        let view = collectionView.dequeue(Reusable.itemBackgroundView, kind: kind, for: indexPath)
        view.backgroundColor = .white
        view.borderedLayer?.borders = []
        return view
      }

    default:
      return collectionView.emptyView(for: indexPath, kind: kind)
    }
  }

  func cellSize(
    collectionView: UICollectionView,
    layout: UICollectionViewFlexLayout,
    indexPath: IndexPath,
    sectionItem: SectionItem
  ) -> CGSize {
    let maxWidth = layout.maximumWidth(forItemAt: indexPath)
    switch sectionItem {
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

  func cellMargin(
    collectionView: UICollectionView,
    layout: UICollectionViewFlexLayout,
    indexPath: IndexPath,
    sectionItem: SectionItem
  ) -> UIEdgeInsets {
    switch sectionItem {
    case .comment:
      let sectionPadding = layout.padding(forSectionAt: indexPath.section)
      let isLast = self.isLast(indexPath, in: collectionView)
      return UIEdgeInsets(
        top: 0,
        left: -sectionPadding.left,
        bottom: isLast ? -sectionPadding.bottom : 0,
        right: -sectionPadding.right
      )

    default:
      return .zero
    }
  }

  func cellPadding(
    collectionView: UICollectionView,
    layout: UICollectionViewFlexLayout,
    indexPath: IndexPath,
    sectionItem: SectionItem
  ) -> UIEdgeInsets {
    switch sectionItem {
    case .comment:
      let sectionPadding = layout.padding(forSectionAt: indexPath.section)
      return UIEdgeInsets(
        top: 10,
        left: sectionPadding.left,
        bottom: 10,
        right: sectionPadding.right
      )

    default:
      return .zero
    }
  }

  func cellVerticalSpacing(
    collectionView: UICollectionView,
    layout: UICollectionViewFlexLayout,
    sectionItem: SectionItem,
    nextSectionItem: SectionItem
  ) -> CGFloat {
    switch (sectionItem, nextSectionItem) {
    case (.comment, .comment): return 0
    case (_, .comment): return 15
    case (.author, _): return 10
    case (.text, _): return 10
    case (.reaction, _): return 10
    case (.comment, _): return 10
    }
  }


  // MARK: Utils

  private func subscribeTapToPresentArticleViewController(
    cell: BaseArticleCardSectionItemCell,
    sectionReactor: SectionReactor
  ) {
    guard self.presentsArticleViewControllerWhenTaps else { return }
    cell.rx.tap
      .subscribe(onNext: { [weak self, weak sectionReactor] in
        guard let `self` = self else { return }
        guard let article = sectionReactor?.currentState.article else { return }
        let articleViewController = self.articleViewControllerFactory(article)
        self.navigator.push(articleViewController)
      })
      .disposed(by: cell.disposeBag)
  }

  private func isFirstComment(_ indexPath: IndexPath, in sectionItems: [SectionItem]) -> Bool {
    let prevItemIndex = indexPath.item - 1
    guard sectionItems.indices.contains(prevItemIndex) else { return true }
    if case .comment = sectionItems[prevItemIndex] {
      return false
    } else {
      return true
    }
  }

  private func isLast(_ indexPath: IndexPath, in collectionView: UICollectionView) -> Bool {
    let lastItem = collectionView.numberOfItems(inSection: indexPath.section) - 1
    return indexPath.item == lastItem
  }
}
