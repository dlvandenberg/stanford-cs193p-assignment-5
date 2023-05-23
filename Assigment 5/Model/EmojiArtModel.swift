//
//  EmojiArtModel.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 22/05/2023.
//

import Foundation

struct EmojiArtModel {
    typealias Location = (x: Int, y: Int)
    
    var background = EmojiArtModel.Background.blank
    var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    init() {}
    
    mutating func addEmoji(_ text: String, at location: Location, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(id: uniqueEmojiId, text: text, x: location.x, y: location.y, size: size))
    }
    
    mutating func removeEmoji(_ emoji: Emoji) {
        emojis.remove(matching: emoji)
    }
    
    
    
    
    
    struct Emoji: Identifiable, Hashable {
        let id: Int
        let text: String
        var x: Int
        var y: Int
        var size: Int
        
        fileprivate init(id: Int, text: String, x: Int, y: Int, size: Int) {
            self.id = id
            self.text = text
            self.x = x
            self.y = y
            self.size = size
        }
    }
}
