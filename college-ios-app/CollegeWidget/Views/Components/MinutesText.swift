//
//  MinutesText.swift
//  CollegeWidget
//

import SwiftUI

extension Text {

    static func minutes(to date: Date) -> Text {
        Text(
            .currentDate,
            format: .offset(to: date, allowedFields: [.minute], maxFieldCount: 1, sign: .never)
        )
    }
}
