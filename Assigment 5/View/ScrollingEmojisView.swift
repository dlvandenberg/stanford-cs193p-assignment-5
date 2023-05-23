//
//  ScrollingEmojisView.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 22/05/2023.
//

import SwiftUI

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct ScrollingEmojisV9iew_Previews: PreviewProvider {
    static let testEmojis: String = "🚀⚽️🥊😊🏈😖👻☠️🤡👿😸💋👁️🧠🫂"
    static var previews: some View {
        ScrollingEmojisView(emojis: testEmojis)
    }
}
