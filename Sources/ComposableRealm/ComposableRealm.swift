import Foundation
import RealmExtensions
import ComposableArchitecture
import RealmSwift



public extension Reducer {

    /// Enhances a `Reducer` with the ability to commit `RealmTransaction` objects
    static func realmReducer(
        action toGlobalAction: CasePath<Action, RealmTransaction>,
        realm toRealm: @escaping (Environment) -> Realm
    ) -> Reducer<State, Action, Environment> {
        Reducer<State, RealmTransaction, Realm> { _, transaction, realm in
            .fireAndForget {
                transaction.write(in: realm)
            }
        }.pullback(
            state: \.self,
            action: toGlobalAction,
            environment: toRealm)
    }
}
