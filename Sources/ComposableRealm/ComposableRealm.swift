import Foundation
import RealmExtensions
import ComposableArchitecture
import RealmSwift


public enum RealmAction: Equatable {

    case commit(RealmTransaction)
    case saveObject(Object)
    case deleteObject(Object)
    case deleteObjects([Object])

}


extension RealmTransaction {

    public func writeEffect(in realm: Realm) -> Effect<RealmAction, Never> {
        .fireAndForget {
            self.write(in: realm)
        }
    }

}


public extension Reducer {

    /// Enhances a `Reducer` with the ability to save `Realm` objects
    static func realmReducer(
        action toGlobalAction: CasePath<Action, RealmAction>,
        realm toRealm: @escaping (Environment) -> Realm
    ) -> Reducer<State, Action, Environment> {
        Reducer<State, RealmAction, Realm> { _, action, realm in
            switch action {

            case .commit(let transaction):
                return transaction
                    .writeEffect(in: realm)

            case .saveObject(let object):
                return RealmTransaction.add(object)
                    .writeEffect(in: realm)

            case .deleteObject(let object):
                return RealmTransaction.delete(object)
                    .writeEffect(in: realm)

            case .deleteObjects(let objects):
                return RealmTransaction.delete(objects)
                    .writeEffect(in: realm)
            }
        }.pullback(
            state: \.self,
            action: toGlobalAction,
            environment: toRealm)
    }
}
