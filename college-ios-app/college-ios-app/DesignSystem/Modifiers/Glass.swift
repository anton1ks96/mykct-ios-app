//
//  Glass.swift
//  college-ios-app
//

import SwiftUI

enum GlassStyle {
    case regular
    case clear
}

enum GlassSupport {
    static var isAvailable: Bool {
        if #available(iOS 26, *) { true } else { false }
    }
}

private struct GlassSurface<S: InsettableShape>: ViewModifier {
    @Environment(\.colors) private var colors

    let shape: S
    let style: GlassStyle
    let tint: Color?
    let interactive: Bool

    @available(iOS 26, *)
    private var glass: Glass {
        var glass: Glass = style == .clear ? .clear : .regular
        if let tint {
            glass = glass.tint(tint)
        }
        if interactive {
            glass = glass.interactive()
        }
        return glass
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(glass, in: shape)
        } else {
            content
                .background(tint ?? colors.surfaceVariant, in: shape)
                .hairline(shape)
        }
    }
}

private struct GlassAction: ViewModifier {
    let tint: Color

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .buttonStyle(.plain)
                .foregroundStyle(tint)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .glassEffect(.regular.interactive(), in: .capsule)
        } else {
            content
                .buttonStyle(.borderedProminent)
                .tint(tint)
                .controlSize(.large)
                .buttonBorderShape(.capsule)
        }
    }
}

private struct AccentAction: ViewModifier {
    @Environment(\.colors) private var colors

    let isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        let shaped = content
            .buttonStyle(.plain)
            .foregroundStyle(isEnabled ? colors.onPrimary : colors.onSurfaceVariant)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)

        if isEnabled {
            shaped.accentGlass(Capsule(), interactive: true)
        } else {
            shaped.glassSurface(Capsule())
        }
    }
}

private struct AccentGlass<S: InsettableShape>: ViewModifier {
    @Environment(\.colors) private var colors

    let shape: S
    let interactive: Bool

    private var gradientOpacity: Double {
        guard GlassSupport.isAvailable else { return 1 }
        return colors.isDark ? 0.7 : 0.95
    }

    func body(content: Content) -> some View {
        content.background {
            ZStack {
                accentGradient.opacity(gradientOpacity)

                if GlassSupport.isAvailable {
                    Color.clear.glassSurface(shape, style: .clear, interactive: interactive)
                }
            }
            .clipShape(shape)
        }
    }
}

private struct GlassMorph<ID: Hashable & Sendable>: ViewModifier {
    let id: ID
    let namespace: Namespace.ID

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffectID(id, in: namespace)
        } else {
            content
        }
    }
}

struct GlassGroup<Content: View>: View {
    var spacing: CGFloat? = 0
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: spacing) { content() }
        } else {
            content()
        }
    }
}

extension View {
    func glassSurface<S: InsettableShape>(
        _ shape: S,
        style: GlassStyle = .regular,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        modifier(GlassSurface(shape: shape, style: style, tint: tint, interactive: interactive))
    }

    func glassSurface(
        style: GlassStyle = .regular,
        tint: Color? = nil,
        interactive: Bool = false
    ) -> some View {
        glassSurface(
            RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous),
            style: style,
            tint: tint,
            interactive: interactive
        )
    }

    func glassAction(tint: Color = .violet) -> some View {
        modifier(GlassAction(tint: tint))
    }

    func accentAction(isEnabled: Bool = true) -> some View {
        modifier(AccentAction(isEnabled: isEnabled))
    }

    func accentGlass<S: InsettableShape>(_ shape: S, interactive: Bool = false) -> some View {
        modifier(AccentGlass(shape: shape, interactive: interactive))
    }

    func glassMorph(id: some Hashable & Sendable, in namespace: Namespace.ID) -> some View {
        modifier(GlassMorph(id: id, namespace: namespace))
    }
}
