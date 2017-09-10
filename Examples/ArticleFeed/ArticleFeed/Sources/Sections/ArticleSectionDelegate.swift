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

final class ArticleSectionDelegate: SectionDelegateType {
  typealias SectionReactor = ArticleSectionReactor

  fileprivate enum Reusable {
    static let authorCell = ReusableCell<ArticleCardAuthorCell>()
    static let textCell = ReusableCell<ArticleCardTextCell>()
    static let reactionCell = ReusableCell<ArticleCardReactionCell>()
    static let commentCell = ReusableCell<ArticleCardCommentCell>()
    static let sectionBackgroundView = ReusableView<UICollectionReusableView>()
    static let itemBackgroundView = ReusableView<UICollectionReusableView>()
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
    sectionItem: SectionItem,
    articleCardAuthorCellDependency: ArticleCardAuthorCell.Dependency,
    articleCardTextCellDependency: ArticleCardTextCell.Dependency,
    articleCardReactionCellDependency: ArticleCardReactionCell.Dependency
  ) -> UICollectionViewCell {
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

  func background(
    collectionView: UICollectionView,
    kind: String,
    indexPath: IndexPath,
    sectionItem: SectionItem
  ) -> UICollectionReusableView {
    switch kind {
    case UICollectionElementKindSectionBackground:
      let view = collectionView.dequeue(Reusable.sectionBackgroundView, kind: kind, for: indexPath)
      view.backgroundColor = .white
      return view

    case UICollectionElementKindItemBackground:
      return collectionView.dequeue(Reusable.itemBackgroundView, kind: kind, for: indexPath)

    default:
      return collectionView.emptyView(for: indexPath, kind: kind)
    }
  }

  func cellVerticalSpacing(
    sectionItem: SectionItem,
    nextSectionItem: SectionItem
  ) -> CGFloat {
    switch (sectionItem, nextSectionItem) {
    case (_, .comment): return 15
    case (.author, _): return 10
    case (.text, _): return 10
    case (.reaction, _): return 10
    case (.comment, _): return 10
    }
  }

  func cellSize(maxWidth: CGFloat, sectionItem: SectionItem) -> CGSize {
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
}
