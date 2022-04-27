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
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.palettes) {palette in
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])){
                        VStack (alignment: .leading) {
                            Text(palette.name).font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete{indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                .onMove{ indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
                
                
            }.navigationTitle("Manage Palettes")
             .navigationBarTitleDisplayMode(.inline)
             . toolbar{
                 EditButton()
             }
             .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .previewDevice("iPhone 8")
            .environmentObject(PaletteStore(named: "Preview"))
            // .preferredColorScheme(.dark)
    }
}
