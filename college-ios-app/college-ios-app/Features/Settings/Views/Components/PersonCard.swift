//
//  PersonCard.swift
//  college-ios-app
//

import SwiftUI

private let cardHeight: CGFloat = 158
private let wideCardHeight: CGFloat = 190
private let portraitRise: CGFloat = 26
private let personCardRadius: CGFloat = 24
private let avatarWidthRatio: CGFloat = 0.58

struct PersonCard: View {
    @Environment(\.colors) private var colors

    let member: TeamMember

    private var height: CGFloat {
        member.isWideShot ? wideCardHeight : cardHeight
    }

    private var outerHeight: CGFloat {
        member.isWideShot ? height : height + portraitRise
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: personCardRadius, style: .continuous)
    }

    private var backdropBlur: CGFloat {
        GlassSupport.isAvailable ? 10 : 18
    }

    private var veilOpacity: Double {
        GlassSupport.isAvailable ? 0.58 : 0.72
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            card

            if !member.isWideShot {
                Image(member.avatar)
                    .resizable()
                    .scaledToFit()
                    .frame(height: outerHeight)
                    .padding(.trailing, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
        .frame(height: outerHeight)
        .padding(.horizontal, 16)
        .accessibilityElement(children: .contain)
    }

    private var card: some View {
        GeometryReader { proxy in
            ZStack {
                veil
                    .allowsHitTesting(false)

                if member.isWideShot {
                    Image(member.avatar)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width * avatarWidthRatio, height: height, alignment: .bottomTrailing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                details
            }
            .frame(width: proxy.size.width, height: height)
            .background {
                Image(member.backdrop)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: backdropBlur)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .clipShape(shape)
        }
        .frame(height: height)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var veil: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: colors.surfaceVariant.opacity(veilOpacity), location: 0),
                    .init(color: colors.primary.opacity(0.18), location: 0.55),
                    .init(color: colors.primary.opacity(0.1125), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Color.clear.glassSurface(shape, style: .clear)
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(member.name)
                .textStyle(AppType.titleMedium)
                .foregroundStyle(colors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(member.role.uppercased())
                .textStyle(AppType.caps)
                .foregroundStyle(colors.onSurface.opacity(0.7))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(.top, 2)
                .accessibilityLabel(member.role)

            GlassGroup(spacing: 0) {
                HStack(spacing: 8) {
                    SocialButton(image: .github, label: "GitHub, \(member.name)", url: member.github)
                    SocialButton(image: .telegram, label: "Telegram, \(member.name)", url: member.telegram)
                }
            }
            .padding(.top, 12)
        }
        .padding(.leading, 18)
        .padding(.trailing, member.isWideShot ? 186 : 140)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct SocialButton: View {
    @Environment(\.colors) private var colors

    let image: ImageResource
    let label: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(colors.onSurface)
                .padding(6)
                .glassSurface(Circle(), interactive: true)
                .overlay(Circle().stroke(.white.opacity(0.3)))
        }
        .accessibilityLabel(label)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(TeamMember.team) { PersonCard(member: $0) }
        }
    }
    .appBackground()
    .environment(\.colors, .dark)
}
