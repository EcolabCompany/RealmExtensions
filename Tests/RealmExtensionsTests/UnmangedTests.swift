import Foundation
import RealmSwift
import XCTest


class UnmanagedTests: RealmTestCase {

    var realm: Realm!

    let luke = Hero.init(
        name: "Luke Skywalker",
        title: "Jedi",
        weapon: "light saber",
        ship: .init(name: "X-Wing"))

    let han = Hero.init(
        name: "Han Solo",
        title: "Scoundrel",
        weapon: "blaster",
        ship: .init(name: "Falcon"))

    let leia = Hero.init(
        name: "Leia Organa",
        title: "Princess",
        weapon: "diplomacy")


    override func setUp() {
        super.setUp()
        realm = try! Realm()

        try! realm.write {
            realm.add([
                luke, han, leia
            ])

            luke.villans.append(objectsIn: [
                .init(
                    name: "Darth Vader",
                    weapon: "intimidation",
                    ship: .init(name: "Tie Fighter")),

                .init(
                    name: "Emperor",
                    weapon: "Lightning",
                    ship: .init(name: "Death Star"))
            ])
        }
    }

    func test_unmanagedObject() {
        // first insure objects are managed
        let managedLuke = realm.object(ofType: Hero.self, forPrimaryKey: "Luke Skywalker")!

        XCTAssertNotNil(managedLuke)
        XCTAssertNotNil(managedLuke.realm)
        XCTAssertNotNil(managedLuke.ship!.realm)
        XCTAssertFalse(managedLuke.villans.isEmpty)
        XCTAssertNotNil(managedLuke.villans.first!.realm)

        let unManagedLuke = managedLuke.unmanaged()

        XCTAssertNotNil(unManagedLuke)
        XCTAssertNil(unManagedLuke.realm)
        XCTAssertNil(unManagedLuke.ship!.realm)
        XCTAssertFalse(managedLuke.villans.isEmpty)
        XCTAssertNil(unManagedLuke.villans.first!.realm)

        //If truely unmanged, we should be able to modify outside of a realm transaction without crashing
        unManagedLuke.weapon = "laser sword"
        unManagedLuke.ship = nil
        unManagedLuke.villans.append(.init(name: "Kylo Ren", weapon: "light saber"))
        unManagedLuke.villans.first!.name = "darth vader"
    }
}
