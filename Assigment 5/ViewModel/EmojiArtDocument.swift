//
//  EmojiArtDocument.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 22/05/2023.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArtModel.Emoji
    typealias Background = EmojiArtModel.Background
    
    @Published private var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageData()
            }
        }
    }
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("🐒", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🐜", at: (50, 100), size: 40)
    }
    
    // MARK: Available to View
    var emojis: [Emoji] { emojiArt.emojis }
    var background: Background { emojiArt.background }
}


// MARK: Intents
extension EmojiArtDocument {
    func setBackground(_ background: Background) {
        emojiArt.background = background
        print("Background set to \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: Location, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func removeEmoji(_ emoji: Emoji) {
        emojiArt.removeEmoji(emoji)
    }
    
    func moveEmoji(_ emoji: Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}

// MARK: Background image fetching
extension EmojiArtDocument {
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        if self?.emojiArt.background == .url(url) {
                            self?.backgroundImageFetchStatus = .idle
                            self?.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank: break
        }
    }
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
}
