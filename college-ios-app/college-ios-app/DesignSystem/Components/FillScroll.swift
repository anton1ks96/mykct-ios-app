//
//  FillScroll.swift
//  college-ios-app
//

import SwiftUI

struct FillScroll<Content: View>: View {
    var fills: Bool
    @ViewBuilder let content: () -> Content

    @State private var topInset: CGFloat = 0
    @State private var height: CGFloat = 0

    var body: some View {
        ScrollView {
            content()
                .frame(minHeight: fills ? height : nil, alignment: .top)
                .environment(\.fillsScroll, fills)
        }
        .onScrollGeometryChange(for: Viewport.self) { geometry in
            Viewport(
                height: geometry.containerSize.height,
                topInset: geometry.contentInsets.top
            )
        } action: { _, viewport in
            topInset = max(topInset, viewport.topInset)
            height = viewport.height - (topInset - viewport.topInset)
        }
    }
}

private struct Viewport: Equatable {
    let height: CGFloat
    let topInset: CGFloat
}

private struct FillsScrollKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var fillsScroll: Bool {
        get { self[FillsScrollKey.self] }
        set { self[FillsScrollKey.self] = newValue }
    }
}

private struct ScrollCentered: ViewModifier {
    @Environment(\.fillsScroll) private var fills

    func body(content: Content) -> some View {
        content
            .frame(maxHeight: fills ? .infinity : nil)
    }
}

extension View {
    func scrollCentered() -> some View {
        modifier(ScrollCentered())
    }
}
