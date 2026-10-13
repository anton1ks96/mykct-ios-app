//
//  SlotHeader.swift
//  CollegeWidget
//

import SwiftUI

struct SlotHeader: View {
    let slot: WidgetSlot

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(WidgetChip.room(slot), WidgetChip.subgroups(slot))
            row(WidgetChip.room(slot) ?? WidgetChip.subgroups(slot), nil)
            row(nil, nil)
        }
    }

    private func row(_ first: WidgetChip?, _ second: WidgetChip?) -> some View {
        HStack(spacing: 8) {
            WidgetPill(text: slot.timeRange)
            first
            second
        }
    }
}
