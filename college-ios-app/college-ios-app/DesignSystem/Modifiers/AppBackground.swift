//
//  AppBackground.swift
//  college-ios-app
//

import SwiftUI

private struct AppBackground: ViewModifier {
    @Environment(\.colors) private var colors

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background {
                ZStack {
                    colors.background
                    AmbientGlow()
                }
                .ignoresSafeArea()
            }
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }
}
