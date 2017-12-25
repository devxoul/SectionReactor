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
  public func with<State, Section>(
    section sectionReactorsClosure: @escaping (State) -> [Section]?
  ) -> Observable<State> where E == State, Section: SectionReactor {
    return self.flatMapLatest { state -> Observable<E> in
      guard let sectionReactors = sectionReactorsClosure(state) else { return .just(state) }
      let sectionStates = Observable.merge(sectionReactors.map { $0.state.skip(1) })
      return Observable.merge(.just(state), sectionStates.map { _ in state })
    }
  }

  public func with<State, Section>(
    section sectionReactorClosure: @escaping (State) -> Section?
  ) -> Observable<State> where E == State, Section: SectionReactor {
    return self.with(section: { state in sectionReactorClosure(state).map { [$0] } })
  }
}

public extension ObservableType {
  public func with<State, Section>(
    section sectionReactorsKeyPath: KeyPath<State, [Section]?>
  ) -> Observable<State> where E == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorsKeyPath] })
  }

  public func with<State, Section>(
    section sectionReactorsKeyPath: KeyPath<State, [Section]>
  ) -> Observable<State> where E == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorsKeyPath] })
  }
}

public extension ObservableType {
  public func with<State, Section>(
    section sectionReactorKeyPath: KeyPath<State, Section?>
  ) -> Observable<State> where E == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorKeyPath] })
  }

  public func with<State, Section>(
    section sectionReactorKeyPath: KeyPath<State, Section>
  ) -> Observable<State> where E == State, Section: SectionReactor {
    return self.with(section: { state in state[keyPath: sectionReactorKeyPath] })
  }
}
