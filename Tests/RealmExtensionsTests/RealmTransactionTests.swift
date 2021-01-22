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


    func test_delete_invalidated() {
        RealmTransaction.add([luke, han]).write(in: realm)
        try! realm.write {
            realm.delete(han)
        }

        RealmTransaction.delete(han).write(in: realm)
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


    func test_delete_multiple_invalidate() {
        RealmTransaction.add([luke, han, leia]).write(in: realm)
        try! realm.write {
            realm.delete(han)
        }
        
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


    // this tests insures that if an object deleted twice for some reason, an error does not occur
    func test_multiple_duplicate_deletes() {
        try! realm.write({
            realm.add(luke, update: .all)
            realm.add(han, update: .all)
            realm.add(leia, update: .all)
        })

        let transaction = RealmTransaction.delete(luke)
            <-> .delete(han)
            <-> .delete(leia)
            <-> .delete(luke)

        transaction.write(in: realm)
    }
    
}



class Hero: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var weapon: String = ""
    @objc dynamic var ship: Ship? = nil
    let villans = List<Villan>()
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    convenience init(
        name: String,
        title: String,
        weapon: String,
        ship: Ship? = nil
    ) {
        self.init()
        self.name = name
        self.title = title
        self.weapon = weapon
        self.ship = ship
    }
}


class Villan: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var weapon: String = ""
    @objc dynamic var ship: Ship? = nil

    override class func primaryKey() -> String? {
        return "name"
    }

    convenience init(
        name: String,
        weapon: String,
        ship: Ship? = nil
    ) {
        self.init()
        self.name = name
        self.weapon = weapon
        self.ship = ship
    }
}


class Ship: Object {
    @objc dynamic var name: String = ""

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
