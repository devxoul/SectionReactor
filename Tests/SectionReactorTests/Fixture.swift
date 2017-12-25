import ReactorKit
import RxDataSources
import RxSwift
@testable import SectionReactor

struct ArticleListSection: SectionModelType {
  var sectionReactor: ArticleSectionReactor
  var items: [ArticleListSectionItem] {
    return self.sectionReactor.currentState.sectionItems
  }

  init(sectionReactor: ArticleSectionReactor) {
    self.sectionReactor = sectionReactor
  }

  init(original: ArticleListSection, items: [ArticleListSectionItem]) {
    self = original
    self.sectionReactor = original.sectionReactor
  }
}

typealias ArticleListSectionItem = Void

final class ArticleListViewReactor: Reactor {
  enum Action {
    case setTitle(String)
    case setSingleSectionReactor(ArticleSectionReactor)
    case appendMultipleSectionReactor(ArticleSectionReactor)
  }

  enum Mutation {
    case setTitle(String)
    case setSingleSectionReactor(ArticleSectionReactor)
    case appendMultipleSectionReactor(ArticleSectionReactor)
  }

  struct State {
    var title: String?

    var singleSectionReactor: ArticleSectionReactor? = nil {
      didSet {
        self.updateSections()
      }
    }
    var multipleSectionReactors: [ArticleSectionReactor]? {
      didSet {
        self.updateSections()
      }
    }
    var sections: [ArticleListSection] = []

    private mutating func updateSections() {
      self.sections.removeAll()
      if let singleSectionReactor = self.singleSectionReactor {
        self.sections.append(ArticleListSection(sectionReactor: singleSectionReactor))
      }
      self.sections += (self.multipleSectionReactors ?? []).map(ArticleListSection.init)
    }
  }

  let initialState: State

  init() {
    defer { _ = self.state }
    self.initialState = State()
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .setTitle(title):
      return .just(.setTitle(title))

    case let .setSingleSectionReactor(sectionReactor):
      return .just(.setSingleSectionReactor(sectionReactor))

    case let .appendMultipleSectionReactor(sectionReactor):
      return .just(.appendMultipleSectionReactor(sectionReactor))
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .setTitle(title):
      newState.title = title

    case let .setSingleSectionReactor(sectionReactor):
      newState.singleSectionReactor = sectionReactor

    case let .appendMultipleSectionReactor(sectionReactor):
      var multipleSectionReactors = newState.multipleSectionReactors ?? []
      multipleSectionReactors.append(sectionReactor)
      newState.multipleSectionReactors = multipleSectionReactors
    }
    return newState
  }

  func transform(state: Observable<State>) -> Observable<State> {
    return state
      .with(section: \State.singleSectionReactor)
      .with(section: \State.multipleSectionReactors)
  }
}


// MARK: - Section Reactor

final class ArticleSectionReactor: SectionReactor {
  enum Action {
    case append
  }

  enum Mutation {
    case appendArticle
  }

  struct State: SectionReactorState {
    var sectionItems: [ArticleListSectionItem] = []
  }

  let initialState: State

  init() {
    defer { _ = self.state }
    self.initialState = State()
  }

  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .append:
      return .just(.appendArticle)
    }
  }

  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case .appendArticle:
      state.sectionItems.append(ArticleListSectionItem())
    }
    return state
  }
}
