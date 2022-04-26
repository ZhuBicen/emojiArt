//
//  PaletteManager.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/4/26.
//

import SwiftUI

struct PaletteManager: View {
    
    @EnvironmentObject var store: PaletteStore
    @Environment(\.colorScheme) var colorScheme
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) {palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])){
                        VStack (alignment: .leading) {
                            Text(palette.name).font(colorScheme == .dark ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                    }
                }
            }.navigationTitle("Manage Palettes")
             .navigationBarTitleDisplayMode(.inline)
             .environment(\.colorScheme, .dark)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .previewDevice("iPhone 8")
            .environmentObject(PaletteStore(named: "Preview"))
            .preferredColorScheme(.dark)
    }
}
