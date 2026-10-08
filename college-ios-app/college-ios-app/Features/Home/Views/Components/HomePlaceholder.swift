//
//  HomePlaceholder.swift
//  college-ios-app
//

import SwiftUI

struct HomePlaceholder<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .scrollCentered()
    }
}
