import Foundation
import RealmSwift


extension ObjectChange {

    var objectChanged: T? {
        guard case .change(let object, _) = self else { return nil }
        return object
    }

}
