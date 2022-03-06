//
//  EmojiClose.swift
//  emojiArt
//
//  Created by Bicen Zhu on 2022/3/6.
//

import SwiftUI

struct FrameWithCloseButton: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                content
                CloseButton()
            }
        }
    }

}

struct CloseButton : Shape {

    func path(in rect: CGRect) -> Path {
        let leftTop = CGPoint(x: rect.maxX*(3/4), y: rect.minY)
        let leftBottom = CGPoint(x: rect.maxX*(3/4), y: rect.maxY*(1/4))
        let rightTop = CGPoint(x: rect.maxX, y: rect.minY)
        let rightBottom = CGPoint(x: rect.maxX, y: rect.maxY*(1/4))
        
        var p = Path()
        p.move(to: leftTop)
        p.addLine(to: leftBottom)
        p.addLine(to: rightBottom)
        p.addLine(to: rightTop)
        p.addLine(to: leftTop)
        p.closeSubpath()
        return p
    }

}

extension View {
    func closable() -> some View {
        self.modifier(FrameWithCloseButton())
    }
}
