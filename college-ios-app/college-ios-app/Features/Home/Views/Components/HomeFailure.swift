//
//  HomeFailure.swift
//  college-ios-app
//

import SwiftUI

struct HomeFailure: View {
    @Environment(\.colors) private var colors

    let message: String
    var retry: String = "Повторить"
    let onRetry: (() -> Void)?

    var body: some View {
        HomePlaceholder {
            if onRetry == nil {
                Image(systemName: "pause.circle")
                    .font(.system(size: 40))
                    .foregroundStyle(colors.onSurfaceVariant)
                    .padding(.bottom, 12)
            }

            Text(message)
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            if let onRetry {
                Button(action: onRetry) {
                    Label(retry, systemImage: "arrow.clockwise")
                }
                .glassAction()
                .frame(maxWidth: 240)
                .padding(.top, 12)
            }
        }
    }
}

#Preview {
    HomeFailure(message: "Не удалось загрузить посещаемость", onRetry: {})
        .padding(.horizontal, Metrics.screenPadding)
        .appBackground()
        .environment(\.colors, .dark)
}
