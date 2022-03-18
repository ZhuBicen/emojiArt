//
//  emojiArtApp.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/2/15.
//

import SwiftUI

@main
struct emojiArtApp: App {
    let document = EmojiArtDocument()
    let palleteStore = PaletteStore(named: "pallette")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
