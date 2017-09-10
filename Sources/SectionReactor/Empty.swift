#if os(iOS) || os(tvOS)
import UIKit

public extension UICollectionView {
  func emptyCell(for indexPath: IndexPath) -> UICollectionViewCell {
    let identifier = "SectionReactor.UICollectionView.emptyCell"
    self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: identifier)
    return self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
  }

  func emptyView(for indexPath: IndexPath, kind: String) -> UICollectionReusableView {
    let identifier = "SectionReactor.UICollectionView.emptyView"
    self.register(UICollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
    return self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath)
  }
}

public extension UITableView {
  func emptyCell(for indexPath: IndexPath) -> UITableViewCell {
    let identifier = "SectionReactor.UITableView.emptyCell"
    self.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
    return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
  }
}
#endif
