import Foundation
import RealmSwift


extension Realm {
  
  ///Convience method for `realm.write`. This first checks if the realm is currently in a write transaction. If it is, it simply calls `f`. If it is not in a write transaction, it will call `f` within `write`.
  public func chainWrite(_ f: () -> ()) {
    if self.isInWriteTransaction {
      f()
    } else {
      try! self.write {
        f()
      }
    }
  }
  
  
  ///Convience method for `realm.write(withoutNotifying:)`. This first checks if the realm is currently in a write transaction. If it is, it simply calls `f`. If it is not in a write transaction, it will call `f` within `write`.
  public func chainWrite(withoutNotifying tokens: [NotificationToken], _ f: () -> ()) {
    if self.isInWriteTransaction {
      f()
    } else {
      try! self.write(withoutNotifying: tokens) {
        f()
      }
    }
  }
  
}
