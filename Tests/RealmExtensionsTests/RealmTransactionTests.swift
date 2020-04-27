import XCTest
import RealmExtensions
import RealmSwift


class RealmTransactionTests: RealmTestCase {
    
    var realm: Realm!
    
    let luke = Hero.init(name: "Luke Skywalker", title: "Jedi", weapon: "light saber")
    let han = Hero.init(name: "Han Solo", title: "Scoundrel", weapon: "blaster")
    let leia = Hero.init(name: "Leia Organa", title: "Princess", weapon: "diplomacy")
    
    override func setUp() {
        super.setUp()
        
        realm = try! Realm()
    }
    
    
    func test_write() {
        let transaction = RealmTransaction.init { realm in
            realm.chainWrite {
                realm.add(self.luke, update: .all)
            }
        }
        
        transaction.write(in: realm)
        
        XCTAssertEqual(realm.objects(Hero.self).count, 1)
        XCTAssertEqual(realm.objects(Hero.self).first!, luke)
    }
    
    
    func test_add() {
        let transaction = RealmTransaction.add(luke)
        transaction.write(in: realm)
        
        XCTAssertEqual(realm.objects(Hero.self).count, 1)
    }
    
    
    func test_add_multple() {
        let transaction = RealmTransaction.add([luke, han])
        transaction.write(in: realm)
        
        XCTAssertEqual(realm.objects(Hero.self).count, 2)
    }
    
    
    func test_delete() {
        RealmTransaction.add([luke, han]).write(in: realm)
        
        let transaction = RealmTransaction.delete(han)
        transaction.write(in: realm)
        
        XCTAssertEqual(realm.objects(Hero.self).count, 1)
        XCTAssertEqual(realm.objects(Hero.self).first!, luke)
    }
    
    
    func test_delete_multiple() {
        RealmTransaction.add([luke, han, leia]).write(in: realm)
        
        let transaction = RealmTransaction.delete([han, leia])
        transaction.write(in: realm)
        
        XCTAssertEqual(realm.objects(Hero.self).count, 1)
        XCTAssertEqual(realm.objects(Hero.self).first!, luke)
    }
    
    
    func test_reduce() {
        let transaction = [
            RealmTransaction.add(luke),
            RealmTransaction.add(han),
            RealmTransaction.add(leia)
        ].reduce()
        transaction.write(in: realm)
        
        XCTAssertEqual(realm.objects(Hero.self).count, 3)
    }
    
    
    func test_keyPath_set() {
        let transaction = leia.set(\.title, "general")
        transaction.write(in: realm)
        
        XCTAssertEqual(leia.title, "general")
    }
    
}



class Hero: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var weapon: String = ""
    
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    convenience init(
        name: String,
        title: String,
        weapon: String
    ) {
        self.init()
        self.name = name
        self.title = title
        self.weapon = weapon
    }
}

