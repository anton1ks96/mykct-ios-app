//
//  SubjectRow.swift
//  college-ios-app
//

import SwiftUI

struct SubjectRow: View {
    @Environment(\.colors) private var colors

    let subject: Subject
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: SubjectIcon.symbol(for: subject.title))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(colors.primary)
                    .frame(width: Metrics.listIconSide, height: Metrics.listIconSide)
                    .background(colors.primary.opacity(0.14), in: Circle())

                Text(subject.title)
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            .padding(16)
            .contentShape(RoundedRectangle(cornerRadius: Metrics.listRowRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .glassSurface(RoundedRectangle(cornerRadius: Metrics.listRowRadius, style: .continuous), interactive: true)
    }
}

#Preview {
    GlassGroup(spacing: 8) {
        VStack(spacing: 8) {
            ForEach(HomeMocks.subjects) { subject in
                SubjectRow(subject: subject, onSelect: {})
            }
        }
    }
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
