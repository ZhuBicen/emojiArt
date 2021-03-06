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
        VStack (spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                documentBody
                Button(action: {
                    document.deleteSelectedEmojis()
                }, label:{
                    Image(systemName: "trash")
                }).padding()
            }
            PalleteChooser()
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
                        .scaleEffect(emojiZoomScale(for: emoji))
                        .position(position(for: emoji, in: geometry))
                        .overlay(
                            document.isEmojiSelected(emoji) ?
                            Rectangle()
                                .stroke(Color.blue, lineWidth: 2)
                                .frame(width: fontSize(for: emoji), height: fontSize(for: emoji), alignment: .bottom)
                                .scaleEffect(emojiZoomScale(for: emoji))
                                .position(position(for: emoji, in: geometry)) : nil)
                        .gesture(emojiDragGesture(for: emoji.id, in: geometry))
                        .onTapGesture {
                            print("Touch emoji \(emoji.id)")
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
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundImageFetchFailedAlert(url)
                default:
                    break
                }
            }
            
        }
    }
    
    @State private var alertToShow : IdentifiableAlert?
    
    private func showBackgroundImageFetchFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed:" + url.absoluteString, alert: {
            Alert(
                title: Text("background image fetch"),
                message: Text("Couldn't fetch image from \(url)."),
                dismissButton: .default(Text("OK"))
            )
        })
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
                        // default emojie front size = 40
                        size: 40
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
    func emojiDragGesture(for id: Int, in geometry: GeometryProxy) -> some Gesture {
        DragGesture()
//            .updating($gestureDragOffset) { latestDragGestureValue, gestureDragOffset, _ in
//                gestureDragOffset = latestDragGestureValue.translation / zoomScale
//                document.updateEmoji(by: gestureDragOffset, emojiId: id)
//            }
            .onChanged {
                gesture in
                    document.updateEmojiPosition(at: convertToEmojiCoordinate(gesture.location, in: geometry), emojiId: id)
            }
//            .onEnded {
//                gesture in
//                    emojiDraggingOffset = gesture.translation
//                    document.updateEmoji(by: emojiDraggingOffset, emojiId: id)
//            }
    }
    
    @State private var steadyZoomStyle: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    @GestureState private var emojiGestureZoomScale: CGFloat = 1
    
    private var zoomScale: CGFloat {
        steadyZoomStyle * gestureZoomScale
    }
    
    private func emojiZoomScale(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        if document.isEmojiSelected(emoji) {
            return steadyZoomStyle * gestureZoomScale * emojiGestureZoomScale
        }
        return steadyZoomStyle * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        if document.hasSelectedEmojis() {
            return MagnificationGesture()
                .updating($emojiGestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                    gestureZoomScale = latestGestureScale
                }
                .onEnded { gestureScaleAtEnd in
                    document.updateSelectedEmojiSize(scale: gestureScaleAtEnd)
                }
        } else {
            return MagnificationGesture()
                .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                    gestureZoomScale = latestGestureScale
                }
                .onEnded { gestureScaleAtEnd in
                    steadyZoomStyle *= gestureScaleAtEnd
                }
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
    
    private func convertToEmojiCoordinate(_ location : CGPoint, in geometry: GeometryProxy) -> (x: CGFloat, y: CGFloat) {
        let center = geometry.frame(in: .local).center

        let location = CGPoint(
            x : (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        return (location.x, location.y)
        
    }
    private func convertFromEmojiCoordinate(_ location: (x: CGFloat, y: CGFloat), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinate((emoji.x, emoji.y), in: geometry)
        
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


