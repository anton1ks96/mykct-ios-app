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

    @Test("Каждый символ словаря есть на минимальной версии iOS")
    func symbolsAvailableOnDeploymentTarget() throws {
        let minimum = try #require(Bundle.main.infoDictionary?["MinimumOSVersion"] as? String)
        let url = try #require(Self.availabilityURL)
        let plist = try #require(NSDictionary(contentsOf: url) as? [String: Any])
        let symbols = try #require(plist["symbols"] as? [String: String])
        let releases = try #require(plist["year_to_release"] as? [String: [String: String]])

        for (title, symbol) in SubjectIcon.icons {
            let version = symbols[symbol].flatMap { releases[$0]?["iOS"] }
            let fits = version.map { $0.compare(minimum, options: .numeric) != .orderedDescending }
            #expect(fits == true, "\(title) -> \(symbol): iOS \(version ?? "?") > \(minimum)")
        }
    }

    @Test("У разных предметов разные символы")
    func symbolsAreUnique() {
        let symbols = SubjectIcon.icons.values
        #expect(Set(symbols).count == symbols.count)
    }

    @Test("Написания ведут на предмет из словаря")
    func aliasesPointToSubjects() {
        for (alias, subject) in SubjectIcon.aliases {
            #expect(SubjectIcon.icons[subject] != nil, "\(alias) -> \(subject)")
            #expect(SubjectIcon.icons[alias] == nil, "\(alias) есть и в словаре")
        }
    }

    @Test("Профильный вариант получает символ предмета")
    func profileVariants() {
        #expect(SubjectIcon.symbol(for: "ТестUI-FE") == SubjectIcon.symbol(for: "ТестИнтерф"))
        #expect(SubjectIcon.symbol(for: "ИПИР-BE") == SubjectIcon.symbol(for: "ИнстРазрИнтерф"))
        #expect(SubjectIcon.symbol(for: "3D-Граф-GD") == SubjectIcon.symbol(for: "3D-КомпГраф"))
        #expect(SubjectIcon.symbol(for: "УчПроект.PM") == SubjectIcon.symbol(for: "УчПроект"))
        #expect(SubjectIcon.symbol(for: "МаркетингGD") != SubjectIcon.symbol(for: "МаркетингПМ"))
    }

    @Test("В словаре нет заглушки")
    func noFallbackInDictionary() {
        #expect(SubjectIcon.icons.values.allSatisfy { $0 != "graduationcap" })
    }

    @Test("Точное совпадение выигрывает у поиска по подстрокам")
    func exactMatchWins() {
        #expect(SubjectIcon.symbol(for: "Химия") == "flask")
        #expect(SubjectIcon.symbol(for: "АрхПаттерны3") == "checkerboard.rectangle")
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

    @Test("Полное название получает символ короткого")
    func keywordMatchesDictionary() {
        #expect(SubjectIcon.symbol(for: "Химия") == SubjectIcon.symbol(for: "Общая химия"))
        #expect(SubjectIcon.symbol(for: "ТеорВер") == SubjectIcon.symbol(for: "Теория вероятностей"))
        #expect(SubjectIcon.symbol(for: "ОргСобрание") == SubjectIcon.symbol(for: "Организационное собрание"))
        #expect(SubjectIcon.symbol(for: "ОБиЗР") == SubjectIcon.symbol(for: "Основы безопасности жизнедеятельности"))
        #expect(SubjectIcon.symbol(for: "Первая медицинская помощь") == "cross.case")
    }

    private static var availabilityURL: URL? {
        [
            "/System/Library/PrivateFrameworks/SFSymbols.framework/CoreGlyphs.bundle",
            "/System/Library/CoreServices/CoreGlyphs.bundle",
        ]
        .lazy
        .compactMap { Bundle(path: $0)?.url(forResource: "name_availability", withExtension: "plist") }
        .first
    }
}
