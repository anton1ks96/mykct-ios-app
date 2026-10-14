//
//  SectionCaps.swift
//  CollegeWatch
//

import SwiftUI

struct SectionCaps: View {
    @Environment(\.colors) private var colors

    let text: String

    var body: some View {
        Text(text.uppercased())
            .textStyle(AppType.caps)
            .foregroundStyle(colors.onSurfaceVariant)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.top, 4)
            .padding(.leading, 4)
    }
}
