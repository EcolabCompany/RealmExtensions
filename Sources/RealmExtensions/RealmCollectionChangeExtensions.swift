import Foundation
import RealmSwift


extension RealmCollectionChange where CollectionType: RealmCollection {

    public var insertions: [CollectionType.Element] {
        guard case .update(let objects, _, let insertions, _) = self else { return [] }
        return insertions.map({ Array(objects)[$0] })
    }

    public var modifications: [CollectionType.Element] {
        guard case .update(let objects, _, _, let modifications) = self else { return [] }
        return modifications.map({ Array(objects)[$0] })
    }

}
