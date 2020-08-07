# RealmExtensions

This package provides handy extensions For **Realm**

## ChainWrite

`chainWrite` is a replacement for *Realm's* `write` function

```swift
public func chainWrite(_ f: () throws -> ()) {
    if self.isInWriteTransaction {
        try! f()
    } else {
        try! self.write {
            try! f()
        }
    }
}
```

This allows you to safely call write transactions when you may already be in a write transaction and not know it

## RealmTransaction

**RealmTransaction** is a struct with a property `transaction: (Realm) -> ()`. This property represents a future Realm database write. 
**RealmTransaction** allow you to build complex Realm database writes by composing smaller transactions together. 

To create a **RealmTransaction**, you can simply call one of the two initializers

```swift
let saveTransaction = RealmTransaction { realm in 
    realm.write {
        realm.add(object)
    }
}
```
or 

```swift
let deleteTransaction = RealmTranscation { 
    try! Realm().delete(anotherObject)
}
```

Then, to commit the transaction to the Realm database, you call

```
saveTransaction.write()
deleteTransaction.write()
```

### Chaining multiple transactions

Often, multiple / complex transactions need to be committed to the database. **RealmTransaction** provides a custom operator to chain multiple transactions together

```swift 
public func <-> (lhs: RealmTransaction, rhs: RealmTransaction) -> RealmTransaction {
    RealmTransaction.init(transaction: lhs.transaction <> rhs.transaction)
}
```
example: 

```swift
let transaction = saveTransaction <-> deleteTransaction
transaction.write()
```
### Convenience Operators

**RealmTransaction** comes with many convenience operators

```swift
public static func add(_ object: Object) -> RealmTransaction
public static func add(_ object: Object?) -> RealmTransaction
public static func add(_ objects: [Object]) -> RealmTransaction
public static func delete(_ object: Object) -> RealmTransaction
public static func delete<S>(_ objects: S) -> RealmTransaction where S: Sequence, S.Element: Object
```

`refresh() -> RealmTransaction` calls `realm.refresh` before the `transaction` is comitted

`public func reduce() -> RealmTransaction` reduces an array of RealmTranscactions down to a single RealmTransaction

`public func set<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, _ value: Value) -> RealmTransaction` allows you to set an Object's property through keyPaths

```swift
let transaction = object.set(\.name, "luke")
```


# Composable Realm
This package provides handy extensions on top of [composable architecture](https://github.com/pointfreeco/swift-composable-architecture)

You can easily extend a `Reducer` to handle all Realm Database transactions with 

```swift

public enum RealmAction {

    case commit(RealmTransaction)
    case saveObject(Object)
    case deleteObject(Object)
    case deleteObjects([Object])

}

static func realmReducer(
    action toGlobalAction: CasePath<Action, RealmAction>,
    realm toRealm: @escaping (Environment) -> Realm
) -> Reducer<State, Action, Environment>

```
