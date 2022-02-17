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
            palete.frame(width: 100)
            documentBody
        }
    }
    
    var documentBody : some View {
        GeometryReader { geometry in
            ZStack {
                Color.yellow
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                    
                }
            }.onDrop(of: [.plainText], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry);
            }
        }
    }
    
    func drop( providers : [NSItemProvider], at location : CGPoint, in geometry: GeometryProxy) -> Bool {
        return providers.loadObjects(ofType: String.self) { string in
            if let emoji = string.first, emoji.isEmoji {
                document.addEmoji(
                    String(emoji),
                    at: convertToEmojiCoordinate(location, in: geometry),
                    size: defaultEmojiFontSize
                )
            }
        }
    }
    
    func fontSize(for emoji : EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func convertToEmojiCoordinate(_ location : CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center

        let location = CGPoint(
            x : location.x - center.x,
            y: location.y - center.y)
        return (Int(location.x), Int(location.y))
        
    }
    private func convertFromEmojiCoordinate(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
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
    
    let testEmojis = "🧳 🌂 ☂️ 🧵 🪡 🪢 🧶 👓 🕶 🥽 🥼 🦺 👔 👕 👖 🧣 🧤 🧥 🧦 👗 👘 🥻 🩴 🩱 🩲 🩳 👙 👚 👛 👜 👝 🎒 👞 👟 🥾 🥿 👠 👡 🩰 👢 👑 👒 🎩 🎓 🧢 ⛑ 🪖 💄 💍 💼"
    
}

struct ScrollingEmojisView : View {
    let emojis: String
    
    var body : some View {
        ScrollView(.vertical){
            VStack {
                ForEach(emojis.map { String($0)}, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag{ NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
