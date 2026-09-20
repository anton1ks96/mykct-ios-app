//
//  HomeFailure.swift
//  college-ios-app
//

import SwiftUI

struct HomeFailure: View {
    @Environment(\.colors) private var colors

    let message: String
    var retry: String = "Повторить"
    let onRetry: () -> Void

    var body: some View {
        HomePlaceholder {
            Text(message)
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Label(retry, systemImage: "arrow.clockwise")
            }
            .glassAction()
            .frame(maxWidth: 240)
            .padding(.top, 12)
        }
    }
}

#Preview {
    HomeFailure(message: "Не удалось загрузить посещаемость", onRetry: {})
        .padding(.horizontal, Metrics.screenPadding)
        .appBackground()
        .environment(\.colors, .dark)
}
