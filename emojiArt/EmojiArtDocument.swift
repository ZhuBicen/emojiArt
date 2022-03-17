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
    @Published
    private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutoSave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageIfNecessary()
            }
        }
    }
    private var autosaveTimer: Timer?
    private func scheduleAutoSave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.autosave()
        }
    }
    enum BackgoundStatus  {
        case fetching, idle
    }
    @Published
    var backgroundStatus = BackgoundStatus.idle
    @Published
    var backgroundImage: UIImage?
    @Published
    var selectedEmojiIds: Set<Int> = []
    

    private struct Autosave {
        static let filename = "autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory? .appendingPathComponent(filename)
        }
    }
    
    
    private func autosave() {
        if let url = Autosave.url {
            save(to:url)
        }
    }
    
    private func save(to url: URL) {
        let thisfunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            print("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            print("\(thisfunction) success")
        }
        catch let encodingError where encodingError is EncodingError {
            print("\(thisfunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
        }
        catch let error {
            print("\(thisfunction) error = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autosaveEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autosaveEmojiArt
            fetchBackgroundImageIfNecessary()
        } else {
            emojiArt = EmojiArtModel()
        }
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
    
    func deleteSelectedEmojis() {
        for emojiId in selectedEmojiIds {
            emojiArt.deleteEmoji(emojiId)
        }
    }
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: CGFloat, y: CGFloat), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: size)
    }
    
    func updateSelectedEmojiSize(scale : CGFloat) {
        for emojiId in selectedEmojiIds {
            emojiArt.updateEmojiSize(scale: scale, emojiId: emojiId)
        }
    }
    func updateEmoji(by offset: CGSize, emojiId: Int) {
        emojiArt.updateEmoji(by: offset, emojiId: emojiId)
    }
    
    func updateEmojiPosition(at location: (x: CGFloat, y: CGFloat), emojiId: Int) {
        emojiArt.updateEmojiPosition(at: location, emojiId: emojiId)
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x = offset.width
            emojiArt.emojis[index].y = offset.height
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size *= scale
        }
    }
}
