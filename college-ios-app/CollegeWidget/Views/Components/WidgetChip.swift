//
//  WidgetChip.swift
//  CollegeWidget
//

import SwiftUI

struct WidgetChip: View {
    let text: String
    let symbol: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .textStyle(AppType.labelLarge)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(.black.opacity(0.18), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.5), lineWidth: 1))
    }
}

extension WidgetChip {

    static func room(_ slot: WidgetSlot) -> WidgetChip? {
        slot.room.isEmpty ? nil : WidgetChip(text: slot.room, symbol: "mappin.and.ellipse")
    }

    static func subgroups(_ slot: WidgetSlot) -> WidgetChip? {
        slot.subgroupCount == 0
            ? nil
            : WidgetChip(text: "Подгруппы: \(slot.subgroupCount)", symbol: "list.bullet")
    }
}
