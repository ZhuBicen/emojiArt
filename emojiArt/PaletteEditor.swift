//
//  PaletteEditor.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/4/23.
//

import SwiftUI

struct PaletteEditor: View {
    
    @Binding var palette: Palette
    // @State private var palette: Palette = PaletteStore(named: "test").palette(at:2)
    
    
    var body: some View {
        Form {
            TextField("Name", text: $palette.name)
        }.frame(minWidth: 300, minHeight: 350)
        
    }
}

//struct PaletteEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        // Text("Fix me")
////        PaletteEditor()
////            .previewLayout(.fixed(width:380, height: 350))
//    }
//}
