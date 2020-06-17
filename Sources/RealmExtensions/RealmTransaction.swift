import Foundation
import RealmSwift


public struct RealmTransaction {
   
    public let transaction: (Realm) -> ()
    
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
    
    
    public static func delete(_ object: Object) -> RealmTransaction {
        .init { realm in
            realm.chainWrite {
                realm.delete(object)
            }
        }
    }
    
    
    public static func delete(_ object: Object?) -> RealmTransaction {
        .init { realm in
            if let object = object {
                realm.chainWrite {
                    realm.delete(object)
                }
            }
        }
    }
    
    
    public static func delete<S>(_ objects: S) -> RealmTransaction where S: Sequence, S.Element: Object {
        .init { realm in
            realm.chainWrite {
                realm.delete(objects)
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
