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
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
