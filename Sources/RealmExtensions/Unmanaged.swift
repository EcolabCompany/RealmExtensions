import Foundation
import RealmSwift


protocol UnmanagedObject: AnyObject {
  func unmanaged() -> Self
}


extension Results {
  public func unmanaged() -> [Element] where Element: Object {
    Array(self.map({ $0.unmanaged() }))
  }
}


extension Object: UnmanagedObject {
  
  /// Creates a 'Deep' un-manged copy
  public func unmanaged() -> Self {
    let detached = type(of: self).init()
    for property in objectSchema.properties {
      guard let value = value(forKey: property.name) else { continue }
      if let unManaged = value as? UnmanagedObject {
        detached.setValue(unManaged.unmanaged(), forKey: property.name)
      } else {
        detached.setValue(value, forKey: property.name)
      }
    }
    return detached
  }
}


extension List: UnmanagedObject where Element: UnmanagedObject {
  
  /// Converts the `List` to a `List` of `UnManaged` objects
  func unmanaged() -> List<Element> {
    let result = List<Element>()
    result.append(objectsIn: self.map({ $0.unmanaged() }))
    return result
  }
  
}
