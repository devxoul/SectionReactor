import XCTest
import ReactorKit
import RxDataSources
import RxExpect
import RxSwift
import RxTest
@testable import SectionReactor

final class SectionReactorTests: XCTestCase {
  func testInitialState() {
    let reactor = ArticleListViewReactor()
    XCTAssertEqual(reactor.currentState.sections.count, 0)
  }

  /// SectionReactors should not affect other mutation and state.
  func testTitle_changes_whenReceivesSetTitleAction() {
    // given
    let reactor = ArticleListViewReactor()

    // when
    reactor.action.onNext(.setTitle("Hello, Single!"))

    // then
    XCTAssertEqual(reactor.currentState.title, "Hello, Single!")
  }

  func testSections_containsSingleSectionReactor_whenReceivesSetSingleSectionReactorAction() {
    // given
    let reactor = ArticleListViewReactor()
    let sectionReactor = ArticleSectionReactor()

    // when
    reactor.action.onNext(.setSingleSectionReactor(sectionReactor))

    // then
    XCTAssertEqual(reactor.currentState.sections.count, 1)
    XCTAssertEqual(reactor.currentState.sections.first?.items.count, 0)
    XCTAssertTrue(reactor.currentState.sections.first?.sectionReactor === sectionReactor)
  }

  func testSections_containsMultipleSectionReactors_whenReceivesAppendMultipleSectionReactorAction() {
    // given
    let reactor = ArticleListViewReactor()
    let sectionReactor = ArticleSectionReactor()

    // when
    reactor.action.onNext(.appendMultipleSectionReactor(sectionReactor))

    // then
    XCTAssertEqual(reactor.currentState.sections.count, 1)
    XCTAssertEqual(reactor.currentState.sections.first?.items.count, 0)
    XCTAssertTrue(reactor.currentState.sections.first?.sectionReactor === sectionReactor)
  }

  func testSingleSectionReactor_createsSectionItems_whenReceivesAppendAction() {
    // given
    let test = RxExpect()
    let reactor = test.retain(ArticleListViewReactor())
    let sectionReactor = ArticleSectionReactor()
    reactor.action.onNext(.setSingleSectionReactor(sectionReactor))

    // when
    test.input(sectionReactor.action, [
      next(100, .append),
      next(200, .append),
    ])

    // then
    test.assert(reactor.state) { events in
      let events = events.in(100...)
      XCTAssertEqual(events.count, 2)
      XCTAssertEqual(events.last?.value.element?.sections.count, 1)
      XCTAssertEqual(events.last?.value.element?.sections.first?.items.count, 2)
    }
  }

  func testMultipleSectionReactors_createsSectionItems_whenReceivesAppendAction() {
    // given
    let test = RxExpect()
    let reactor = test.retain(ArticleListViewReactor())
    let sectionReactors: [ArticleSectionReactor] = [.init(), .init()]
    sectionReactors.forEach { reactor.action.onNext(.appendMultipleSectionReactor($0)) }

    // when
    test.input(sectionReactors[0].action, [
      next(100, .append),
    ])
    test.input(sectionReactors[1].action, [
      next(100, .append),
      next(200, .append),
      next(300, .append),
    ])

    // then
    test.assert(reactor.state) { events in
      let events = events.in(100...)
      XCTAssertEqual(events.count, 4)
      XCTAssertEqual(events.last?.value.element?.sections.count, 2)
      XCTAssertEqual(events.last?.value.element?.sections[0].items.count, 1)
      XCTAssertEqual(events.last?.value.element?.sections[1].items.count, 3)
    }
  }
}
