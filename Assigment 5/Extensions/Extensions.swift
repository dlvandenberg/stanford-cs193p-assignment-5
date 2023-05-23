//
//  Extensions.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 22/05/2023.
//

import SwiftUI

// MARK: Collection.indexMatching
extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

// MARK: RangeReplaceableCollection.removeMatching
extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(matching element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        }
    }
}


// MARK: Set.toggleMatching
extension Set where Element: Identifiable {
    mutating func toggle(matching element: Element) {
        if contains(element) {
            let _ = remove(element)
            print("Removed element \(element) from Set [\(self.count)]")
        } else {
            insert(element)
            print("Added element \(element) to Set [\(self.count)]")
        }
    }
}

extension Set where Element == Int {
    mutating func toggle(matching element: Element) {
        if contains(element) {
            let _ = remove(element)
            print("Removed element \(element) from Set [\(self.count)]")
        } else {
            insert(element)
            print("Added element \(element) to Set [\(self.count)]")
        }
    }
}


// MARK: CGRect.center
extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}


// MARK: Character.isEmoji
extension Character {
    var isEmoji: Bool {
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}



// MARK: Array of NSItemProviders.loadObject(s)
extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            provider.loadObject(ofClass: theType) { object, error in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType )}) {
            let _ = provider.loadObject(ofClass: theType) { object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
    
    func loadObjects<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
}


// MARK: URL.imageURL
extension URL {
    var imageURL: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        
        return baseURL ?? self
    }
}

// MARK: CGSize center/+/-/*/'/'
extension CGSize {
    var center: CGPoint {
        CGPoint(x: width / 2, y: height / 2)
    }
    
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}


// MARK: CGPoint.translation
extension CGPoint {
    func translation(to point: CGPoint) -> CGSize {
        CGSize(width: point.x - self.x, height: point.y - self.y)
    }
    
    static func -(lhs: Self, rhs: Self) -> CGSize {
            CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
    static func +(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    static func -(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}


// MARK:
extension DragGesture.Value {
    var distance: CGSize {
        location - startLocation
    }
}
