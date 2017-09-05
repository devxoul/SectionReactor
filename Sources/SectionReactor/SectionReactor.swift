import ReactorKit
import RxDataSources
import RxSwift

public protocol SectionReactorState {
  associatedtype SectionItem
  var sectionItems: [SectionItem] { get }
}

public protocol SectionReactor: Reactor {
  associatedtype State: SectionReactorState
}

public extension SectionReactor {
  public func section<Section>(
    _ section: ([Section.Item]) -> Section,
    _ sectionItem: (Self.State.SectionItem) -> Section.Item
  ) -> Section where Section: SectionModelType {
    let sectionItems = self.currentState.sectionItems.map(sectionItem)
    return section(sectionItems)
  }

  public func section<Section>(
    _ section: ([Section.Item]) -> Section
  ) -> Section where Section: SectionModelType, Self.State.SectionItem == Section.Item {
    let sectionItems = self.currentState.sectionItems
    return section(sectionItems)
  }
}

public extension Array where Element: SectionReactor {
  public func sections<Section>(
    _ section: ([Section.Item]) -> Section,
    _ sectionItem: (Element.State.SectionItem) -> Section.Item
  ) -> [Section] where Section: SectionModelType {
    return self.map { $0.section(section, sectionItem) }
  }

  public func sections<Section>(
    _ section: ([Section.Item]) -> Section
  ) -> [Section] where Section: SectionModelType, Element.State.SectionItem == Section.Item {
    return self.map { $0.section(section) }
  }
}

public extension Reactor {
  public func merge<S, R>(
    _ state: Observable<S>,
    _ sectionReactorSelectors: ((S) -> [R])...
  ) -> Observable<S> where R: SectionReactor {
    let sectionStatesDidChange: Observable<S> = state.flatMap { state -> Observable<S> in
      let sectionReactors = sectionReactorSelectors.flatMap { $0(state) }
      let sectionStates = Observable.merge(sectionReactors.map { $0.state })
      return sectionStates.map { _ in state }
    }
    return Observable.merge(state, sectionStatesDidChange)
  }
}
