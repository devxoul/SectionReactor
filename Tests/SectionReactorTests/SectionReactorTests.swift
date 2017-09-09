import XCTest
import ReactorKit
import RxDataSources
import RxExpect
import RxSwift
import RxTest
@testable import SectionReactor

final class SectionReactorTests: XCTestCase {
  func testInitialState_single() {
    let reactor = ArticleListViewReactor(testType: .single)
    XCTAssertEqual(reactor.currentState.sections.count, 3)
    XCTAssertEqual(reactor.currentState.sections[0].items.count, 0)
    XCTAssertEqual(reactor.currentState.sections[1].items.count, 0)
    XCTAssertEqual(reactor.currentState.sections[2].items.count, 0)
  }

  func testInitialState_multiple() {
    let reactor = ArticleListViewReactor(testType: .multiple)
    XCTAssertEqual(reactor.currentState.sections.count, 3)
    XCTAssertEqual(reactor.currentState.sections[0].items.count, 0)
    XCTAssertEqual(reactor.currentState.sections[1].items.count, 0)
    XCTAssertEqual(reactor.currentState.sections[2].items.count, 0)
  }

  func testInitialState_both() {
    let reactor = ArticleListViewReactor(testType: .both)
    XCTAssertEqual(reactor.currentState.sections.count, 3)
    XCTAssertEqual(reactor.currentState.sections[0].items.count, 0)
    XCTAssertEqual(reactor.currentState.sections[1].items.count, 0)
    XCTAssertEqual(reactor.currentState.sections[2].items.count, 0)
  }

  func testSections_areChanged_whenSingleSectionReactorIsChanged() {
    RxExpect { test in
      let reactor = test.retain(ArticleListViewReactor(testType: .single))
      test.input(reactor.currentState.singleSectionReactor.action, [
        next(100, .append),
        next(200, .append),
      ])
      test.assert(reactor.state.map { $0.sections.count }).since(200).equal([3])
      test.assert(reactor.state.map { $0.sections[0].items.count }).since(200).equal([2])
      test.assert(reactor.state.map { $0.sections[1].items.count }).since(200).equal([0])
      test.assert(reactor.state.map { $0.sections[2].items.count }).since(200).equal([0])
    }
  }

  func testSections_areChanged_whenMultipleSectionReactorsAreChanged() {
    RxExpect { test in
      let reactor = test.retain(ArticleListViewReactor(testType: .multiple))
      test.input(reactor.currentState.multipleSectionReactors[0].action, [
        next(100, .append),
        next(200, .append),
        next(300, .append),
      ])
      test.input(reactor.currentState.multipleSectionReactors[1].action, [
        next(400, .append),
      ])
      test.assert(reactor.state.map { $0.sections.count }).since(400).equal([3])
      test.assert(reactor.state.map { $0.sections[0].items.count }).since(400).equal([0])
      test.assert(reactor.state.map { $0.sections[1].items.count }).since(400).equal([3])
      test.assert(reactor.state.map { $0.sections[2].items.count }).since(400).equal([1])
    }
  }

  func testSections_areChanged_whenBothSectionReactorsAreChanged() {
    RxExpect { test in
      let reactor = test.retain(ArticleListViewReactor(testType: .both))
      test.input(reactor.currentState.singleSectionReactor.action, [
        next(100, .append),
        next(200, .append),
        next(300, .append),
      ])
      test.input(reactor.currentState.multipleSectionReactors[0].action, [
        next(400, .append),
      ])
      test.input(reactor.currentState.multipleSectionReactors[1].action, [
        next(500, .append),
        next(600, .append),
      ])
      test.assert(reactor.state.map { $0.sections.count }).since(600).equal([3])
      test.assert(reactor.state.map { $0.sections[0].items.count }).since(600).equal([3])
      test.assert(reactor.state.map { $0.sections[1].items.count }).since(600).equal([1])
      test.assert(reactor.state.map { $0.sections[2].items.count }).since(600).equal([2])
    }
  }
}


// MARK: - Section Model

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


// MARK: - View Reactor

final class ArticleListViewReactor: Reactor {
  enum Action {}
  enum Mutation {}

  struct State {
    var singleSectionReactor: ArticleSectionReactor
    var multipleSectionReactors: [ArticleSectionReactor]
    var sections: [ArticleListSection] {
      var sections: [ArticleListSection] = []
      sections.append(ArticleListSection(sectionReactor: self.singleSectionReactor))
      sections += self.multipleSectionReactors.map(ArticleListSection.init)
      return sections
    }
  }

  enum TestType {
    case single
    case multiple
    case both
  }

  let initialState: State
  let testType: TestType

  init(testType: TestType) {
    defer { _ = self.state }
    self.initialState = State(
      singleSectionReactor: ArticleSectionReactor(),
      multipleSectionReactors: [ArticleSectionReactor(), ArticleSectionReactor()]
    )
    self.testType = testType
  }

  func transform(state: Observable<State>) -> Observable<State> {
    switch self.testType {
    case .single:
      return state.merge(sections: [{ $0.singleSectionReactor }])

    case .multiple:
      return state.merge(sections: [{ $0.multipleSectionReactors }])

    case .both:
      return state.merge(sections: [
        { [$0.singleSectionReactor] },
        { $0.multipleSectionReactors },
      ])
    }
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
