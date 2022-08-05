//
//  TransitionExtensions.swift
//  Example-app
//
//  Created by Olof Thorén on 2022-08-02.
//

import SwiftUI

struct FoldModifier: ViewModifier {
    let amount: Double
    let anchor: UnitPoint

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(amount), axis: (x: 1, y:0, z: 0), anchor: anchor)
            .clipped()
    }
}

extension AnyTransition {
    static var fold: AnyTransition {
        .modifier(
            active: FoldModifier(amount: -90, anchor: .top),
            identity: FoldModifier(amount: 0, anchor: .top)
        )
    }
}
