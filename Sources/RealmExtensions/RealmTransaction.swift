import Foundation
import RealmSwift

public var SideEffects = RealmTransactionEnvironment.live()

/// A way to control side effects. Handy for testing
public struct RealmTransactionEnvironment {
  var uuid: () -> UUID
}

extension RealmTransactionEnvironment {
  
  internal static func live() -> Self {
    .init(uuid: UUID.init)
  }
  
  
  /// Used only for testing.
  /// Over rides UUID generationg to easily tell if `RealmTransaction` objects are equal
  public static func mock(
    uuid: @escaping () -> UUID = { UUID.init(uuidString: "00000000-0000-0000-0000-000000000000")! }
  ) -> RealmTransactionEnvironment {
    .init(uuid: uuid)
  }
  
}


public struct RealmTransaction {
  public let transaction: (Realm) -> ()
  
  fileprivate let uuid: UUID = SideEffects.uuid()
  
  public init(transaction: @escaping (Realm) -> ()) {
    self.transaction = transaction
  }
  
  public init(f: @escaping () -> ()) {
    self.transaction = { realm in
      realm.chainWrite(f)
    }
  }
  
  public static func write(in realm: Realm = try! Realm()) -> (RealmTransaction) -> () {
    { $0.transaction(realm) }
  }
  
  public func write(in realm: Realm = try! Realm()) {
    transaction(realm)
  }
  
  public static func add(_ object: Object) -> RealmTransaction {
    .init { realm in
      realm.chainWrite {
        realm.add(object, update: .modified)
      }
    }
  }
  
  public static func add(_ object: Object?) -> RealmTransaction {
    .init { realm in
      guard let object = object else { return }
      realm.chainWrite {
        realm.add(object, update: .modified)
      }
    }
  }
  
  public static func add<S>(_ objects: S) -> RealmTransaction where S: Sequence, S.Element: Object {
    .init { realm in
      realm.chainWrite {
        realm.add(objects, update: .modified)
      }
    }
  }
  
  public static func create<T: Object>(_ type: T.Type, value: Any) -> RealmTransaction {
    .init { realm in
      realm.chainWrite {
        realm.create(type, value: value, update: .modified)
      }
    }
  }
  
  public static func create<T: Object>(_ type: T.Type) -> (Any) -> RealmTransaction {
    { value in
        .init { realm in
          realm.chainWrite {
            realm.create(type, value: value, update: .modified)
          }
        }
    }
  }
  
  
  public static func delete(_ object: Object) -> RealmTransaction {
    return .init { realm in
      guard object.realm != nil, !object.isInvalidated else { return }
      realm.chainWrite {
        realm.delete(object)
      }
    }
  }
  
  public static func delete(_ object: Object?) -> RealmTransaction {
    guard let object = object else { return .empty }
    return .init { realm in
      guard object.realm != nil, !object.isInvalidated else { return }
      realm.chainWrite {
        realm.delete(object)
      }
    }
  }
  
  public static func delete<S>(_ objects: S) -> RealmTransaction where S: Sequence, S.Element: Object {
    .init { realm in
      let validObjects = objects.filter({ $0.isInvalidated == false && $0.realm != nil })
      realm.chainWrite {
        realm.delete(validObjects)
      }
    }
  }
  
  public func refresh() -> RealmTransaction {
    .init { realm in
      realm.refresh()
      self.transaction(realm)
    }
  }
  
  
  ///Returns a `RealmTransaction` that does nothing
  public static var empty: RealmTransaction {
    .init(f: {})
  }
  
}


extension RealmTransaction: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.uuid == rhs.uuid
  }
  
}


extension Array where Element == RealmTransaction {
  
  ///Reduces an array of `RealmTransaction`s to a single `RealmTransaction`
  public func reduce() -> RealmTransaction {
    guard let head = self.first else { return RealmTransaction.init {} }
    return self.dropFirst().reduce(head, <->)
  }
  
}


public protocol RealmTransactionPropertySettable {}

extension RealmTransactionPropertySettable where Self: Object {
  
  /// Sets an `Object`'s property through a keyPath
  public func set<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, _ value: Value) -> RealmTransaction {
    .init { realm in
      realm.chainWrite {
        self[keyPath: keyPath] = value
      }
    }
  }
}


extension Object: RealmTransactionPropertySettable {}
