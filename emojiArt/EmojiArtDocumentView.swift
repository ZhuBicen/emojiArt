//
//  ContentView.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/2/15.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject
    var document: EmojiArtDocument
    
    var body: some View {
        HStack (spacing: 0){
            palete.frame(width: 100).zIndex(1.0)
            documentBody
        }
    }
    
    var documentBody : some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoordinate((0, 0), in: geometry))
                )
                    .gesture(doubleTapeZoom(in: geometry.size))
                
                if document.backgroundStatus == .fetching {
                    ProgressView().scaleEffect(2)
                }
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .scaleEffect(zoomScale)
                        .position(position(for: emoji, in: geometry))
                        .overlay(
                            document.isEmojiSelected(emoji) ?
                            Rectangle()
                                .strokeBorder()
                                .frame(width: fontSize(for: emoji), height: fontSize(for: emoji), alignment: .bottom)
                                .scaleEffect(zoomScale)
                                .position(position(for: emoji, in: geometry)) : nil)
                        .gesture(emojiDragGesture(for: emoji.id))
                        .onTapGesture {
                            document.toggleSelectedEmoji(emoji)
                        }
                }
            }
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry);
            }
            .onTapGesture {
                document.deselectAllEmojis()
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            
        }
    }
    
    func drop( providers : [NSItemProvider], at location : CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { uiImage in
                if let data = uiImage.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoordinate(location, in: geometry),
                        size: defaultEmojiFontSize * 2
                    )
                }
            }
        }
        return found
    }
    
    func fontSize(for emoji : EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var geasturePanOffset: CGSize = CGSize.zero
    
    @State private var steadyDragOffset: CGSize = .zero
    @GestureState private var gestureDragOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + geasturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($geasturePanOffset) { latestDragGestureValue, geasturePanOffset, _ in
                geasturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    @State var emojiDraggingOffset: CGSize = .zero
    func emojiDragGesture(for id: Int) -> some Gesture {
        DragGesture()
//            .updating($gestureDragOffset) { latestDragGestureValue, gestureDragOffset, _ in
//                gestureDragOffset = latestDragGestureValue.translation / zoomScale
//                document.updateEmoji(by: gestureDragOffset, emojiId: id)
//            }
//            .onChanged {
//                gesture in
//                    emojiDraggingOffset = gesture.translation
//                    document.updateEmoji(by: emojiDraggingOffset, emojiId: id)
//            }
            .onEnded {
                gesture in
                    emojiDraggingOffset = gesture.translation
                    document.updateEmoji(by: emojiDraggingOffset, emojiId: id)
            }
    }
    
    @State private var steadyZoomStyle: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyZoomStyle * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyZoomStyle *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapeZoom(in size: CGSize) -> some Gesture {
        TapGesture(count:2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image : UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.width > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyZoomStyle = min(hZoom, vZoom)
        }
    }
    
    private func convertToEmojiCoordinate(_ location : CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center

        let location = CGPoint(
            x : (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (Int(location.x), Int(location.y))
        
    }
    private func convertFromEmojiCoordinate(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinate((emoji.x, emoji.y), in: geometry)
        
    }
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var palete : some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size:defaultEmojiFontSize))
    }
    
    let testEmojis = "🧳🌂☂️🧵"
    
}

struct ScrollingEmojisView : View {
    let emojis: String
    
    var body : some View {
        ScrollView(.vertical){
            ForEach(emojis.map { String($0)}, id: \.self) { emoji in
                Text(emoji)
                    .onDrag{ NSItemProvider(object: emoji as NSString) }
            }
        }
    }
}


struct Highlight: ViewModifier {
    
    func body(content: Content) -> some View {
        content.border(Color.blue)
    }
    
}

extension View {
    func highlight() -> some View {
        self.modifier(Highlight())
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}


