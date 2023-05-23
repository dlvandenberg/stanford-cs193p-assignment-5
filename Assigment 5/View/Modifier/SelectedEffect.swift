//
//  SelectedView.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 22/05/2023.
//

import SwiftUI

struct SelectedEffect: ViewModifier {
    
    let emoji: EmojiArtDocument.Emoji
    let emojiSet: Set<EmojiArtDocument.Emoji>
    
    func body(content: Content) -> some View {
        content.overlay {
            emojiSet.contains(emoji) ? RoundedRectangle(cornerRadius: Constants.selectionCornerRadius)
                .stroke(Constants.selectionStrokeColor, lineWidth: Constants.selectionStrokeWidth) : nil
        }
    }
}

extension View {
    func selectedEffect(for emoji: EmojiArtDocument.Emoji, in set: Set<EmojiArtDocument.Emoji>) -> some View {
        modifier(SelectedEffect(emoji: emoji, emojiSet: set))
    }
}

fileprivate struct Constants {
    static let selectionCornerRadius: CGFloat = 10
    static let selectionStrokeColor = Color.cyan
    static let selectionStrokeWidth: CGFloat = 4
}
