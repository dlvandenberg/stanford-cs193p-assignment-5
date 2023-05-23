//
//  EmojiArtDocumentView.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 22/05/2023.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArtDocument.Emoji
    typealias Background  = EmojiArtDocument.Background
    
    @ObservedObject var document: EmojiArtDocument
    
    @State private var showDeleteDialog = false
    @State private var deletingEmoji: Emoji?
    
    @State private var steadyZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyZoomScale * (emojiSelected ? 1 : gestureZoomScale)
    }
    private var selectedEmojiScale: CGFloat {
        steadyZoomScale * (emojiSelected ? gestureZoomScale : 1)
    }
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    @GestureState private var gestureMoveOffset = CGSize.zero

    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    let testEmojis = "🚀⚽️🥊😊🏈😖👻☠️🤡👿😸💋👁️🧠🫂🦹‍♂️🧚🏻👼🏼👨🏽‍🦽🦈🦑🪼🦕🦖🪰🐜🐌🐛🦇🐺🦅🦉🪳🪱"
    
    @State private var selectedEmojiIds = Set<Int>()
    @State private var movingEmoji: Emoji?
    
    private var selectedEmojis: Set<Emoji> {
        var selectedEmojis = Set<Emoji>()
        for id in selectedEmojiIds {
            selectedEmojis.insert(document.emojis.first(where: {$0.id == id})!)
        }
        return selectedEmojis
    }
    
    private var emojiSelected: Bool {
        !selectedEmojis.isEmpty
    }
    
}

// MARK: Views
extension EmojiArtDocumentView {
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .position(convertFromEmojiCoordinates((0, 0), in: geometry))
                        .scaleEffect(zoomScale)
                )
                .gesture(doubleTapToZoom(in: geometry.size).exclusively(before: deselectEmojisGesture()))
                
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(Constants.spinnerScale)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .padding(Constants.emojiPadding)
                            .selectedEffect(for: emoji, in: selectedEmojis)
                            .scaledFont(size: fontSize(for: emoji), factor: zoomScale(for: emoji))
                            .position(position(for: emoji, in: geometry))
                            .gesture(selectionGesture(on: emoji).simultaneously(with: moveGesture(emoji)).simultaneously(with: longPressDeleteGesture(on: emoji)))
                    }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            .gesture((emojiSelected ? AnyGesture(moveGesture().map { _ in () }) : AnyGesture(panGesture().map { _ in () })).simultaneously(with: zoomGesture()))
            .alert("Delete \(deletingEmoji?.text ?? "?")", isPresented: $showDeleteDialog) {
                Button("Delete", role: .destructive) {
                    guard let emoji = deletingEmoji else {
                        return
                    }
                    document.removeEmoji(emoji)
                    deletingEmoji = nil
                }
                Button("Cancel", role: .cancel) {
                    deletingEmoji = nil
                }
            }
        
        }
    }
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: Constants.defaultEmojisFontSize))
    }
}

fileprivate struct Constants {
    static let spinnerScale: CGFloat = 2
    static let defaultEmojisFontSize: CGFloat = 40
    static let emojiPadding: CGFloat = 1
}

// MARK: Emoji Size / Positioning
extension EmojiArtDocumentView {
    private func position(for emoji: Emoji, in geometry: GeometryProxy) -> CGPoint {
        // If an unselected emoji is being dragged -> use offset if that is this emoji
        // Otherwise check if emoji is in selected emojis -> use offset if that is the case
        if let movingEmoji = movingEmoji {
            return conditionalPosition(for: emoji, in: geometry) {
                emoji == movingEmoji
            }
        } else {
            return conditionalPosition(for: emoji, in: geometry) {
                selectedEmojis.contains(emoji)
            }
        }
    }
    
    private func conditionalPosition(for emoji: Emoji, in geometry: GeometryProxy, _ condition: () -> Bool) -> CGPoint {
        if condition() {
            return convertFromEmojiCoordinates((emoji.x + Int(gestureMoveOffset.width), emoji.y + Int(gestureMoveOffset.height)), in: geometry)
        } else {
            return convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
        }
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
}

// MARK: Coordinate conversion
extension EmojiArtDocumentView {
    private func convertFromEmojiCoordinates(_ location: Location, in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> Location {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale)
        
        return (Int(location.x), Int(location.y))
    }
}

// MARK: (Drag-and-) Drop support
extension EmojiArtDocumentView {
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        
        if !found {
            found =  providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(String(emoji),
                                      at: convertToEmojiCoordinates(location, in: geometry),
                                      size: Constants.defaultEmojisFontSize / zoomScale)
                }
            }
        }
        
        return found
    }
}

// MARK: Deselecting
extension EmojiArtDocumentView {
    private func deselectEmojisGesture() -> some Gesture {
        TapGesture().onEnded {
            withAnimation {
                print("Deselecting emojis")
                selectedEmojiIds = []
            }
        }
    }
}

// MARK: Selecting
extension EmojiArtDocumentView {
    private func selectionGesture(on emoji: Emoji) -> some Gesture {
        TapGesture().onEnded {
            withAnimation {
                print("Selecting emoji: \(emoji)")
                selectedEmojiIds.toggle(matching: emoji.id)
            }
        }
    }
}

// MARK: Zooming / scaling
extension EmojiArtDocumentView {
    private func zoomScale(for emoji: Emoji) -> CGFloat {
        if selectedEmojis.contains(emoji) {
            return selectedEmojiScale
        } else {
            return zoomScale
        }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        guard let image,
              image.size.width > 0,
              image.size.height > 0,
              size.width > 0,
              size.height > 0 else {
            return
        }
        
        let hZoom = size.width / image.size.width
        let vZoom = size.height / image.size.height
        steadyStatePanOffset = .zero
        steadyZoomScale = min(hZoom, vZoom)
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation {
                print("Zooming to fit")
                zoomToFit(document.backgroundImage, in: size)
            }
        }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScale in
                if emojiSelected {
                    DispatchQueue.main.async {
                        selectedEmojis.forEach {
                            document.scaleEmoji($0, by: gestureScale)
                        }
                    }
                } else {
                    steadyZoomScale *= gestureScale
                }
            }
    }
}

// MARK: Panning
extension EmojiArtDocumentView {
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { dragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + dragGestureValue.translation / zoomScale
            }
    }
}

// MARK: Moving emojis
extension EmojiArtDocumentView {
    private func moveGesture(_ emoji: Emoji? = nil) -> some Gesture {
        return DragGesture()
            .updating($gestureMoveOffset) { latestDragGestureValue, gestureMoveOffset, _ in
                DispatchQueue.main.async { movingEmoji = emoji }
                gestureMoveOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { dragGestureValue in
                withAnimation {
                    move(emoji: emoji, offset: dragGestureValue.distance / zoomScale)
                }
            }
    }
    
    private func move(emoji: Emoji?, offset: CGSize) {
        DispatchQueue.main.async {
            if let emoji = emoji {
                if selectedEmojis.contains(emoji) {
                    moveSelectedEmojis(by: offset)
                } else {
                    // MARK: Extra Credit 1 - Move grabbed emoji (which is unselected)
                    document.moveEmoji(emoji, by: offset)
                }
            } else {
                moveSelectedEmojis(by: offset)
            }
        }
    }
    
    private func moveSelectedEmojis(by offset: CGSize) {
        selectedEmojis.forEach {
            document.moveEmoji($0, by: offset)
        }
    }
}

// MARK: Deleting Emojis
extension EmojiArtDocumentView {
    private func longPressDeleteGesture(on emoji: Emoji) -> some Gesture {
        LongPressGesture()
            .onEnded { finished in
                deletingEmoji = emoji
                showDeleteDialog = finished
            }
    }
}






struct EmojiArtDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
