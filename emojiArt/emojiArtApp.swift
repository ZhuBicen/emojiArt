//
//  emojiArtApp.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/2/15.
//

import SwiftUI

@main
struct emojiArtApp: App {
    @StateObject var document = EmojiArtDocument()
    @StateObject var palleteStore = PaletteStore(named: "pallette")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
                .environmentObject(palleteStore)
        }
    }
}
