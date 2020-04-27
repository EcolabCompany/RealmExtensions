import Foundation
import RealmSwift
import XCTest


class RealmTestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
}
