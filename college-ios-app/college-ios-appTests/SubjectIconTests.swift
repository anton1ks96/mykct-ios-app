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

    @Test("Каждый символ словаря есть на минимальной версии iOS")
    func symbolsAvailableOnDeploymentTarget() throws {
        let minimum = try #require(
            Bundle.main.infoDictionary?["MinimumOSVersion"] as? String,
            "Тесты должны запускаться внутри приложения"
        )
        let releases = try #require(
            Self.symbolReleases(),
            "В рантайме симулятора не нашлась база SF Symbols name_availability.plist"
        )

        for (subject, symbol) in SubjectIcon.icons {
            #expect(UIImage(systemName: symbol) != nil, "\(subject) -> \(symbol)")
            let version = releases[symbol]
            let fits = version.map { $0.compare(minimum, options: .numeric) != .orderedDescending }
            #expect(fits == true, "\(subject) -> \(symbol): iOS \(version ?? "?") > \(minimum)")
        }
    }

    @Test("У разных предметов разные символы")
    func symbolsAreUnique() {
        let symbols = SubjectIcon.icons.values
        #expect(Set(symbols).count == symbols.count)
        #expect(!symbols.contains(SubjectIcon.placeholder))
    }

    @Test("Написания ведут на предмет из словаря")
    func aliasesPointToSubjects() {
        for (alias, subject) in SubjectIcon.aliases {
            #expect(SubjectIcon.icons[subject] != nil, "\(alias) -> \(subject)")
            #expect(SubjectIcon.icons[alias] == nil, "\(alias) есть и в словаре")
        }
    }

    @Test("Каждое название портала находится без поиска по подстрокам")
    func portalTitlesResolve() {
        for title in Self.portalTitles {
            #expect(SubjectIcon.subject(for: title) != nil, "\(title)")
        }
    }

    @Test("Профильный вариант получает символ предмета")
    func profileVariants() {
        #expect(SubjectIcon.subject(for: "ТестUI-FE") == "ТестИнтерф")
        #expect(SubjectIcon.subject(for: "ИПИР-BE") == "ИнстРазрИнтерф")
        #expect(SubjectIcon.subject(for: "ИПИР-UI") == "ИнстРазрИнтерф")
        #expect(SubjectIcon.subject(for: "3D-Граф-GD") == "3D-КомпГраф")
        #expect(SubjectIcon.subject(for: "УчПроект.PM") == "УчПроект")
        #expect(SubjectIcon.subject(for: "МикросервисыFE") == "Микросервисы")
        #expect(SubjectIcon.subject(for: "РевьюКодаFE") == "РевьюКода")
        #expect(SubjectIcon.subject(for: "МаркетингПМ") == "МаркетингПМ")
    }

    @Test("UI без разделителя - часть названия, а не профиль")
    func uiIsNotGluedProfile() {
        #expect(SubjectIcon.subject(for: "Тест") == nil)
        #expect(SubjectIcon.subject(for: "РазрBE") == nil)
        #expect(SubjectIcon.subject(for: "ТестUI") == "ТестИнтерф")
    }

    @Test("Точное совпадение выигрывает у поиска по подстрокам")
    func exactMatchWins() {
        #expect(SubjectIcon.symbol(for: "Химия") == "flask")
        #expect(SubjectIcon.symbol(for: "АрхПаттерны3") == "checkerboard.rectangle")
        #expect(SubjectIcon.symbol(for: " Математика ") == "function")
    }

    @Test("Полное название получает символ короткого")
    func keywordMatchesDictionary() {
        let pairs = [
            ("Базы данных", "СУБД"),
            ("Физическая культура", "Физкульт"),
            ("Разработка программных модулей", "РазработкаПО"),
            ("Численные методы", "ЧислМетоды"),
            ("Структуры данных", "АиСД"),
            ("Общая химия", "Химия"),
            ("Физическая химия", "Химия"),
            ("Теория вероятностей", "ТеорВер"),
            ("Графический дизайн", "ГрафДизайн"),
            ("Иностранный язык в профессиональной деятельности", "АнглЯзПро"),
            ("Инженерное мышление", "ИнжМыш"),
            ("Критическое мышление", "КритМыш"),
            ("Архитектурные паттерны", "АрхПаттерны"),
            ("История технологий", "ИстТехно"),
            ("Организационное собрание", "ОргСобрание"),
            ("Основы безопасности жизнедеятельности", "ОБиЗР"),
            ("Первая медицинская помощь", "Медицина"),
        ]
        for (title, subject) in pairs {
            #expect(SubjectIcon.symbol(for: title) == SubjectIcon.icons[subject], "\(title)")
        }
    }

    @Test("Незнакомое название даёт заглушку")
    func unknownTitle() {
        #expect(SubjectIcon.symbol(for: "Ксенобиология Марса") != SubjectIcon.placeholder)
        #expect(SubjectIcon.symbol(for: "Абвгд") == SubjectIcon.placeholder)
    }

    private static func symbolReleases() -> [String: String]? {
        let paths = [
            "/System/Library/PrivateFrameworks/SFSymbols.framework/CoreGlyphs.bundle",
            "/System/Library/CoreServices/CoreGlyphs.bundle",
        ]
        let url = paths.lazy
            .compactMap { Bundle(path: $0) }
            .compactMap { $0.url(forResource: "name_availability", withExtension: "plist") }
            .first
        guard let url,
              let plist = NSDictionary(contentsOf: url) as? [String: Any],
              let symbols = plist["symbols"] as? [String: String],
              let years = plist["year_to_release"] as? [String: [String: String]]
        else { return nil }
        return symbols.compactMapValues { years[$0]?["iOS"] }
    }

    private static let portalTitles = [
        "2D-Граф", "2D-КомпГраф", "3D-Граф-GD", "3D-Интерф", "3D-Интерфейсы", "3D-КомпГраф",
        "BE-Production", "Frameworks", "GameDev-2(1)", "GameDev-2(2)", "GameDev-3(3)",
        "GameDev-практ", "Hardware", "React", "UML-BE", "UML-FE", "UX/UI дизайн", "UnityC#", "АиСД",
        "АиСД-2BE", "АктМаст", "АлгоТруд-3", "АналитикаUX", "АнглЯз", "АнглЯзПро", "АнлгЯзПро",
        "АрхПаттерны", "АрхПаттерны3", "Астрономия", "Биология", "Буткемп", "В.Сборы", "ВВСпец",
        "ВВСпец-П", "ВведСпец", "ВведениеООП", "Веб-Дизайн", "ВебДизайн", "ВидыПроект", "Выставка",
        "ГрафДизайн", "ГруппаПроекта", "Демоэкзамен", "ДигиДиз", "ДизДиджитал", "ДизИнтерфейсов",
        "ДизМедиа", "ДискрМат", "ИПИР-FE", "ИПИР-GD", "ИПИР-PM", "ИПИР-UI", "ИТ-инфр-проект",
        "ИТ-инфр-разв", "ИТ-инфр-экспл", "ИгроДев", "ИгроМаркетинг", "ИгроМех", "ИнжМыш",
        "ИнстРазрИнтерф", "ИнтегрПО", "ИнтегрПО2", "ИнтерфДиз", "ИнфоБез", "ИстТехно", "История",
        "ИсторияТ", "КейсыПроекта", "КейсыПроектов", "Колористика", "КомпСети", "Композиция",
        "КреативМ", "КритМыш", "Литер", "Литература", "ЛичБренд", "МаркетингGD", "МаркетингПМ",
        "Математика", "Микросервисы", "МикросервисыBE", "МикросервисыFE", "Нормоконтроль", "ОБиЗР",
        "ОКРиУП", "Обществознание", "ОперСистем", "ОперСистемы", "ОргСобрание", "ОсновыML",
        "ОтрасПР", "ПОПД", "ПарадПроекта", "ПарадигмыПроект", "Подгруппы", "Подгруппы-1к",
        "Подгруппы-2к", "Подгруппы-3к", "Предзащита", "ПредпрКлас", "Предпринимат", "Предприятия",
        "ПрогрC#", "ПродРазр", "Проект", "Проект-3", "Проект-ИТ-ИНФ", "ПроектированиеБП",
        "ПроектыБП", "ПроизвПракт.01", "ПрофПредмет", "ПсихОбщен", "ПсихоПроекта", "ПсихологияБП",
        "Развер-ИТ-ИНФ", "РазрUI", "РазрUI-FE", "РазрUI-GD", "РазрUI-PM", "РазрИгрИнтерф",
        "РазрИнтерф", "РазрПО-П", "РазработкаИгрП", "РазработкаПО", "РазработкаПО-1",
        "РазработкаПО-2", "РевьюИгроКейс2", "РевьюИгроКейс3", "РевьюКодаGD", "РусЯз", "СУБД",
        "СУБД-1", "СУБД-2", "СУБД-проектирование", "СопрИгрПрод", "СтилиДиз", "СтилиДизайн", "ТРИЗ",
        "ТеорВер", "ТестUI", "ТестUI-FE", "ТестUI-GD", "ТестUI-PM", "ТестИнтерф", "ТестИнтерфейс",
        "ТестИнтерфейсов", "Тестирование", "ТехДокиРус", "УпрИТ-проект", "УчПракт.UI", "УчПракт.БП",
        "УчПракт03", "УчПракт04", "УчПракт06", "УчПроект", "УчПроект.BE", "УчПроект.FE",
        "УчПроект.PM", "УчПроект02", "Физика", "Физкульт", "Физкультура", "Философия", "ФинГрамота",
        "ФормПроекта", "ФорумБудущего", "Химия", "ЧислМетоды", "Экономика", "Экспл-ИТ-ИНФ",
        "ЭлВышМат", "ЭлДок", "ЭтапыПроекта",
    ]
}
