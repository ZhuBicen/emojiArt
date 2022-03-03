//
//  EmojiArtDocument.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/2/15.
//

import Foundation


import SwiftUI

class EmojiArtDocument: ObservableObject
{
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageIfNecessary()
            }
        }
    }
    enum BackgoundStatus  {
        case fetching, idle
    }
    @Published var backgroundStatus = BackgoundStatus.idle
    @Published var backgroundImage: UIImage?
    @Published
    var selectedEmojiIds: Set<Int> = []
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("🏀", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🐯", at: (200,  100), size: 80)
    }
    
    func fetchBackgroundImageIfNecessary() {
        backgroundImage = nil
        backgroundStatus = .fetching
        switch(emojiArt.background) {
        case .url(let url):
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                if imageData != nil {
                    DispatchQueue.main.async {[weak self] in
                        self? .backgroundStatus = .idle
                        if self? .emojiArt.background == EmojiArtModel.Background.url(url) {
                            self? .backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }

        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    var emojis: [EmojiArtModel.Emoji] {
        emojiArt.emojis
    }
    
    var background: EmojiArtModel.Background {
        emojiArt.background
    }
    
    func isEmojiSelected(_ emoji: EmojiArtModel.Emoji) -> Bool {
        selectedEmojiIds.contains(emoji.id)
    }
    
    func toggleSelectedEmoji(_ emoji: EmojiArtModel.Emoji) {
        if isEmojiSelected(emoji) {
            deselectEmoji(emoji)
        } else {
            selectedEmojiIds.insert(emoji.id)
        }
    }
    
    func deselectEmoji(_ emoji: EmojiArtModel.Emoji) {
        selectedEmojiIds.remove(emoji.id)
    }
    
    func deselectAllEmojis() {
        selectedEmojiIds = []
    }
    
    func hasSelectedEmojis() -> Bool {
        !selectedEmojiIds.isEmpty
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("Set background \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func updateSelectedEmojiSize(scale : CGFloat) {
        for emojiId in selectedEmojiIds {
            emojiArt.updateEmojiSize(scale: scale, emojiId: emojiId)
        }
    }
    func updateEmoji(by offset: CGSize, emojiId: Int) {
        emojiArt.updateEmoji(by: offset, emojiId: emojiId)
    }
    
    func updateEmojiPosition(at location: (x: Int, y: Int), emojiId: Int) {
        emojiArt.updateEmojiPosition(at: location, emojiId: emojiId)
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x = Int(offset.width)
            emojiArt.emojis[index].y = Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}
