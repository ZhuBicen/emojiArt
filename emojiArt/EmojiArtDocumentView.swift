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
        VStack (spacing: 0){
            documentBody
            palete
        }
    }
    
    var documentBody : some View {
        Color.yellow
    }
    
    var palete : some View {
        ScrollingEmojisView(emojis: testEmojis)
    }
    
    let testEmojis = "🧳 🌂 ☂️ 🧵 🪡 🪢 🧶 👓 🕶 🥽 🥼 🦺 👔 👕 👖 🧣 🧤 🧥 🧦 👗 👘 🥻 🩴 🩱 🩲 🩳 👙 👚 👛 👜 👝 🎒 👞 👟 🥾 🥿 👠 👡 🩰 👢 👑 👒 🎩 🎓 🧢 ⛑ 🪖 💄 💍 💼"
    
}

struct ScrollingEmojisView : View {
    let emojis: String
    
    var body : some View {
        ScrollView(.horizontal){
            HStack {
                ForEach(emojis.map { String($0)}, id: \.self) { emoji in
                    Text(emoji)
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
