//
//  AnimatableSystemFontModifier.swift
//  Assigment 5
//
//  Created by Dennis van den Berg on 23/05/2023.
//

import SwiftUI

// MARK: Extra Credit 2 - Scaled font modifier
struct ScaledFont: AnimatableModifier {
    let size: CGFloat
    var factor: Double
    
    var animatableData: Double {
        get { factor }
        set { factor = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size * factor))
    }
}

extension View {
    func scaledFont(size: CGFloat, factor: Double) -> some View {
        modifier(ScaledFont(size: size, factor: factor))
    }
}
