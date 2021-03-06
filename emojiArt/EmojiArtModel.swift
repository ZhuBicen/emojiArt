//
//  EmojiArtModel.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/2/15.
//

import Foundation
import SwiftUI


struct EmojiArtModel: Codable {
    var background = Background.blank
    
    var emojis = [Emoji]()
    
    struct Emoji : Identifiable, Hashable, Codable {
        let text: String
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        let id: Int
        
        fileprivate init(text: String, x: CGFloat, y: CGFloat, size: CGFloat, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
        
    }
    
    func json() throws -> Data {
        try JSONEncoder().encode(self)
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    init() {}
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: CGFloat, y: CGFloat), size: CGFloat) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
        
    }
    
    mutating func deleteEmoji(_ emojiId: Int) {
        emojis.removeAll{$0.id == emojiId}
    }
    
    mutating func updateEmoji(by offset: CGSize, emojiId: Int) {
        for (index, value) in emojis.enumerated() {
            if value.id == emojiId {
                emojis[index].x += offset.width
                emojis[index].y += offset.height
                break
            }
        }
    }
    
    mutating func updateEmojiPosition(at location: (x: CGFloat, y: CGFloat), emojiId: Int) {
        for (index, value) in emojis.enumerated() {
            if value.id == emojiId {
                emojis[index].x = location.x
                emojis[index].y = location.y
                break
            }
        }
    }
    
    mutating func updateEmojiSize(scale : CGFloat, emojiId: Int) {
        for (index, value) in emojis.enumerated() {
            if value.id == emojiId {
                emojis[index].size *= scale
                break
            }
        }
    }
}
