import Foundation
import RealmSwift


extension ObjectChange {
  
  public var objectChanged: T? {
    guard case .change(let object, _) = self else { return nil }
    return object
  }
  
}
