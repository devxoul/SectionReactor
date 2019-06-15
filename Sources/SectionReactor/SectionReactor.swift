import Foundation
import ReactorKit
import RxDataSources
import RxSwift

public protocol SectionReactorState {
  associatedtype SectionItem
  var sectionItems: [SectionItem] { get }
}

public typealias _SectionReactor = SectionReactor
public protocol SectionReactor: Reactor where State: SectionReactorState {
}

public extension ObservableType {
  func with<State, Section>(
    section sectionReactorsClosure: @escaping (State) -> [Section]?
  ) -> Observable<State> where Element == State, Section: SectionReactor {
    return self.flatMapLatest { state -> Observable<Element> in
      guard let sectionReactors = sectionReactorsClosure(state) else { return .just(state) }
      let sectionStates = Observable.merge(sectionReactors.map { $0.state.skip(1) })
      return Observable.merge(.just(state), sectionStates.map { _ in state })
    }
  }

  func with<State, Section>(
    section sectionReactorClosure: @escaping (State) -> Section?
  ) -> Observable<State> where Element == State, Section: SectionReactor {
    return self.with(section: { state in sectionReactorClosure(state).map { [$0] } })
  }
}

public extension ObservableType {
  func with<State, Section>(
    section sectionReactorsKeyPath: KeyPath<State, [Section]?>
  ) -> Observable<State> where Element == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorsKeyPath] })
  }

  func with<State, Section>(
    section sectionReactorsKeyPath: KeyPath<State, [Section]>
  ) -> Observable<State> where Element == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorsKeyPath] })
  }
}

public extension ObservableType {
  func with<State, Section>(
    section sectionReactorKeyPath: KeyPath<State, Section?>
  ) -> Observable<State> where Element == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorKeyPath] })
  }

  func with<State, Section>(
    section sectionReactorKeyPath: KeyPath<State, Section>
  ) -> Observable<State> where Element == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorKeyPath] })
  }
}
