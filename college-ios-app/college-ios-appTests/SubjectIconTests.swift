//
//  SubjectIconTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
import UIKit
@testable import college_ios_app

@Suite("Иконки предметов")
struct SubjectIconTests {

    @Test("Каждый символ словаря есть в системе")
    func symbolsExist() {
        for (title, symbol) in SubjectIcon.icons {
            #expect(UIImage(systemName: symbol) != nil, "\(title) -> \(symbol)")
        }
    }

    @Test("В словаре нет заглушки")
    func noFallbackInDictionary() {
        #expect(SubjectIcon.icons.values.allSatisfy { $0 != "graduationcap" })
    }

    @Test("Точное совпадение выигрывает у поиска по подстрокам")
    func exactMatchWins() {
        #expect(SubjectIcon.symbol(for: "Химия") == "flask")
        #expect(SubjectIcon.symbol(for: "АрхПаттерны3") == "building.2")
        #expect(SubjectIcon.symbol(for: " Математика ") == "function")
    }

    @Test("Полные названия находятся поиском по подстрокам")
    func keywordFallback() {
        #expect(SubjectIcon.symbol(for: "Базы данных") == "cylinder.split.1x2")
        #expect(SubjectIcon.symbol(for: "Физическая культура") == "figure.run")
        #expect(SubjectIcon.symbol(for: "Разработка программных модулей")
            == "chevron.left.forwardslash.chevron.right")
    }

    @Test("Незнакомое название даёт заглушку")
    func unknownTitle() {
        #expect(SubjectIcon.symbol(for: "Ксенобиология Марса") != "graduationcap")
        #expect(SubjectIcon.symbol(for: "Абвгд") == "graduationcap")
    }
}
