//
//  ArticleViewSetion.swift
//  ArticleFeed
//
//  Created by Suyeol Jeon on 07/09/2017.
//  Copyright © 2017 Suyeol Jeon. All rights reserved.
//

import RxDataSources

enum ArticleViewSection {
  case article(ArticleSectionReactor)
}

extension ArticleViewSection: SectionModelType {
  var items: [ArticleViewSectionItem] {
    switch self {
    case let .article(sectionReactor):
      return sectionReactor.currentState.sectionItems.map {
        ArticleViewSectionItem(sectionReactor: sectionReactor, sectionItem: $0)
      }
    }
  }

  init(original: ArticleViewSection, items: [ArticleViewSectionItem]) {
    self = original
  }
}

struct ArticleViewSectionItem {
  let sectionReactor: ArticleSectionReactor
  let sectionItem: ArticleSectionReactor.SectionItem
}
