//
//  AppDependency.swift
//  ArticleFeed
//
//  Created by Suyeol Jeon on 08/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import UIKit

import URLNavigator

struct AppDependency {
  let window: UIWindow
  let rootViewController: UIViewController
}

extension AppDependency {
  static func resolve() -> AppDependency {
    let articleService = ArticleService()
    let navigator = Navigator()

    let articleSectionReactorFactory: (Article) -> ArticleSectionReactor = { article in
      return ArticleSectionReactor(
        article: article,
        authorCellReactorFactory: ArticleCardAuthorCellReactor.init,
        textCellReactorFactory: ArticleCardTextCellReactor.init,
        reactionCellReactorFactory: ArticleCardReactionCellReactor.init,
        commentCellReactorFactory: ArticleCardCommentCellReactor.init
      )
    }

    var articleViewControllerFactory: ((Article) -> ArticleViewController)!
    articleViewControllerFactory = { article in
      return ArticleViewController(
        reactor: ArticleViewReactor(
          article: article,
          articleSectionReactorFactory: articleSectionReactorFactory
        ),
        articleSectionDelegate: ArticleSectionDelegate(
          navigator: navigator,
          articleViewControllerFactory: articleViewControllerFactory,
          presentsArticleViewControllerWhenTaps: true
        )
      )
    }

    let articleListViewReactor = ArticleListViewReactor(
      articleService: articleService,
      articleSectionReactorFactory: articleSectionReactorFactory
    )
    let articleListViewController = ArticleListViewController(
      reactor: articleListViewReactor,
      articleSectionDelegate: ArticleSectionDelegate(
        navigator: navigator,
        articleViewControllerFactory: articleViewControllerFactory,
        presentsArticleViewControllerWhenTaps: false
      )
    )

    return .init(
      window: UIWindow(),
      rootViewController: UINavigationController(rootViewController: articleListViewController)
    )
  }
}
