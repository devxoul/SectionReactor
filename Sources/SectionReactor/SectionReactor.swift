import ReactorKit
import RxDataSources
import RxSwift

public protocol SectionReactorState {
  associatedtype SectionItem
  var sectionItems: [SectionItem] { get }
}

public typealias _SectionReactor = SectionReactor
public protocol SectionReactor: Reactor {
  associatedtype State: SectionReactorState
}

public extension ObservableType {
  public func merge<State, R>(
    sections sectionReactorSelectors: [((State) -> [R])]
  ) -> Observable<State> where E == State, R: SectionReactor {
    let sectionStatesDidChange: Observable<E> = self.flatMap { state -> Observable<E> in
      let sectionReactors = sectionReactorSelectors.flatMap { $0(state) }
      let sectionStates = Observable.merge(sectionReactors.map { $0.state })
      return sectionStates.map { _ in state }
    }
    return Observable.merge(self.asObservable(), sectionStatesDidChange)
  }

  public func merge<State, R>(
    sections sectionReactorSelectors: [((State) -> R)]
  ) -> Observable<State> where E == State, R: SectionReactor {
    let sectionReactorArraySelectors: [((State) -> [R])] = sectionReactorSelectors.map { selector in
      { state in [selector(state)] }
    }
    return self.merge(sections: sectionReactorArraySelectors)
  }
}
