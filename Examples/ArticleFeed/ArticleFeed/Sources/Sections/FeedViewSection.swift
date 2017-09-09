//
//  ArticleListViewSection.swift
//  ArticleFeed
//
//  Created by Suyeol Jeon on 01/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxDataSources

enum ArticleListViewSection {
  case article(ArticleSectionReactor)
}

extension ArticleListViewSection: SectionModelType {
  var items: [ArticleListViewSectionItem] {
    switch self {
    case let .article(sectionReactor):
      return sectionReactor.currentState.sectionItems.map(ArticleListViewSectionItem.articleCard)
    }
  }

  init(original: ArticleListViewSection, items: [ArticleListViewSectionItem]) {
    self = original
  }
}

enum ArticleListViewSectionItem {
  case articleCard(ArticleSectionReactor.SectionItem)
}
