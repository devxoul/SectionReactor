# SectionReactor

SectionReactor is a ReactorKit extension for managing table view and collection view sections with RxDataSources.

## Getting Started

This is a draft. I have no idea how would I explain this concept 🤦‍♂️ It would be better to see the [ArticleFeede](https://github.com/devxoul/SectionReactor/tree/master/Examples/ArticleFeed) example.

**ArticleViewSection.swift**

```swift
enum ArticleViewSection: SectionModelType {
  case article(ArticleSectionReactor)

  var items: [ArticleViewSection] {
    switch self {
    case let .article(sectionReactor):
      return sectionReactor.currentState.sectionItems
    }
  }
}
```

**ArticleSectionReactor.swift**

```swift
import SectionReactor

final class ArticleSectionItem: SectionReactor {
  struct State: SectionReactorState {
    var sectionItems: [ArticleSectionItem]
  }
}
```

**ArticleListViewReactor.swift**

```swift
final class ArticleListViewReactor: Reactor {
  struct State {
    var articleSectionReactors: [ArticleSectionReactor]
    var sections: [ArticleViewSection] {
      return self.articleSectionReactors.map(ArticleViewSection.article)
    }
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state.merge(sections: [
      { $0.articleSectionReactors },
    ])
  }
}
```

## License

SectionReactor is under MIT license. See the [LICENSE](LICENSE) for more info.
