//
//  LoginBackdrop.swift
//  college-ios-app
//

import SwiftUI

struct LoginBackdrop: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Color.darkBackground
            .overlay(alignment: .top) {
                TimelineView(.animation(paused: reduceMotion)) { timeline in
                    let time = Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3600))

                    Image("LoginBackdrop")
                        .resizable()
                        .scaledToFill()
                        .visualEffect { content, proxy in
                            content.distortionEffect(
                                ShaderLibrary.ribbonWave(.float2(proxy.size), .float(time)),
                                maxSampleOffset: CGSize(width: 12, height: 12)
                            )
                        }
                }
            }
            .clipped()
            .overlay {
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.40),
                        .init(color: Color.darkBackground.opacity(0.94), location: 0.65),
                        .init(color: Color.darkBackground, location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

private struct LoginBackdropModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background { LoginBackdrop() }
            .environment(\.colors, .dark)
            .preferredColorScheme(.dark)
    }
}

extension View {
    func loginBackdrop() -> some View {
        modifier(LoginBackdropModifier())
    }
}

#Preview {
    LoginBackdrop()
}
