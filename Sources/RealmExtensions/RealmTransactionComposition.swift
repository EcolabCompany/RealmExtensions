import Foundation


///Combines two `RealmTransaction` objects into a single `RealmTransaction` object by appling a `Realm` object to the first's `transaction` function, then applying the `Realm` object to the second's `transaction` function.

precedencegroup RealmTransactionComposition {
    associativity: left
}

infix operator <->: RealmTransactionComposition

public func <-> (lhs: RealmTransaction, rhs: RealmTransaction) -> RealmTransaction {
    RealmTransaction.init { realm in
      try lhs.transaction(realm)
      try rhs.transaction(realm)
    }
}
