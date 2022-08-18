import Foundation
import RealmSwift


extension Realm {
  
  ///Convience method for `realm.write`. This first checks if the realm is currently in a write transaction. If it is, it simply calls `f`. If it is not in a write transaction, it will call `f` within `write`.
  public func chainWrite(_ f: () throws -> ()) throws {
    if self.isInWriteTransaction {
      try f()
    } else {
      try self.write {
        try f()
      }
    }
  }
  
  
  ///Convience method for `realm.write(withoutNotifying:)`. This first checks if the realm is currently in a write transaction. If it is, it simply calls `f`. If it is not in a write transaction, it will call `f` within `write`.
  public func chainWrite(withoutNotifying tokens: [NotificationToken], _ f: () throws -> ()) throws {
    if self.isInWriteTransaction {
      try f()
    } else {
      try self.write(withoutNotifying: tokens) {
        try f()
      }
    }
  }
  
}
