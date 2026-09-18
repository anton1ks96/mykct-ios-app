//
//  SlideFade.swift
//  college-ios-app
//

import SwiftUI

private struct Shift: ViewModifier {
    let dx: CGFloat

    func body(content: Content) -> some View {
        content.offset(x: dx)
    }
}

extension AnyTransition {
    static func slideFade(_ dx: CGFloat) -> AnyTransition {
        .asymmetric(
            insertion: .modifier(active: Shift(dx: dx), identity: Shift(dx: 0))
                .combined(with: .opacity),
            removal: .modifier(active: Shift(dx: -dx), identity: Shift(dx: 0))
                .combined(with: .opacity)
        )
    }
}
