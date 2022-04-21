//
//  PalleteChooser.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/4/17.
//

import SwiftUI

struct PalleteChooser: View {
    var emojiFontSize :CGFloat = 40
    var emojiFont : Font {.system(size: emojiFontSize)}
    
    @EnvironmentObject var store: PaletteStore
    @State private var chosenPaletteIndex = 0
    
    var body: some View {
        let palette = store.palette(at: chosenPaletteIndex)
        HStack {
            palleteControlButton
            body(for: palette)
        }.clipped()
    }
    
    var palleteControlButton: some View {
        Button {
            withAnimation {
                chosenPaletteIndex = (chosenPaletteIndex + 1) %  store.palettes.count
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTransition)
    }
    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
    }
        
}


struct ScrollingEmojisView : View {
    let emojis: String
    
    var body : some View {
        ScrollView(.horizontal){
            HStack{
                // removingDuplicateCharacters
                ForEach(emojis.map { String($0)}, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag{ NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}
