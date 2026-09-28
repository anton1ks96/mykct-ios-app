//
//  SubjectIcon.swift
//  college-ios-app
//

import Foundation

nonisolated enum SubjectIcon {

    static let placeholder = "graduationcap"

    private static let profileSuffixes: [String] = {
        let ids = StudyProfile.all.map(\.id)
        let separated = (ids + ["UI"]).flatMap { ["-\($0)", ".\($0)"] }
        return separated + ids
    }()

    static func symbol(for title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = subject(for: trimmed) ?? keywordSubject(in: trimmed)
        return subject.flatMap { icons[$0] } ?? placeholder
    }

    static func subject(for title: String) -> String? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return known(trimmed) ?? withoutProfile(trimmed).flatMap(known)
    }

    private static func known(_ title: String) -> String? {
        let subject = aliases[title] ?? title
        return icons[subject] == nil ? nil : subject
    }

    private static func withoutProfile(_ title: String) -> String? {
        guard let suffix = profileSuffixes.first(where: {
            title.hasSuffix($0) && title.count > $0.count
        }) else { return nil }
        return String(title.dropLast(suffix.count))
    }

    private static func keywordSubject(in title: String) -> String? {
        let name = title.lowercased().replacingOccurrences(of: "ё", with: "е")
        func has(_ parts: String...) -> Bool { parts.contains { name.contains($0) } }

        if has("физкультур", "спорт") || (has("физическ") && has("культур")) {
            return "Физкульт"
        }
        if has("мышлен") && has("инженерн") { return "ИнжМыш" }
        if has("мышлен") && has("критическ") { return "КритМыш" }

        if (has("баз") && has("данн")) || has("субд", "sql") { return "СУБД" }
        if has("сети", "сетев", "маршрутизац", "телекоммуникац") { return "КомпСети" }
        if has("операционн", "linux", "windows") { return "ОперСистемы" }
        if has("дискретн") { return "ДискрМат" }
        if has("алгоритм") || (has("структур") && has("данн")) { return "АиСД" }
        if has("тестирован", "отладк", "качеств") { return "Тестирование" }
        if has("мобильн", "android", "ios") { return "Мобильная разработка" }
        if has("веб", "web", "сайт", "html", "фронтенд") { return "Веб-Дизайн" }
        if has("криптограф")
            || (has("безопасн") && has("информ", "данн"))
            || (has("защит") && has("информ")) { return "ИнфоБез" }
        if has("паттерн") { return "АрхПаттерны" }
        if has("разработ", "программ", "модул", "информатик") { return "РазработкаПО" }
        if has("аппаратн", "эвм", "архитектур", "схемотехник") { return "Hardware" }

        if has("русск", "родн") { return "РусЯз" }
        if has("литератур") { return "Литер" }
        if has("английск", "иностран") && has("профессиональн") { return "АнглЯзПро" }
        if has("английск", "иностран", "язык") { return "АнглЯз" }

        if has("статистик", "вероятност") { return "ТеорВер" }
        if has("численн") { return "ЧислМетоды" }
        if has("высш") && has("матем") { return "ЭлВышМат" }
        if has("математик", "матем") { return "Математика" }
        if has("астроном") { return "Астрономия" }
        if has("хими") { return "Химия" }
        if has("физик") { return "Физика" }
        if has("биолог", "естествознан", "эколог") { return "Биология" }
        if has("географ") { return "География" }

        if has("истори") && has("технолог") { return "ИстТехно" }
        if has("истори") { return "История" }
        if has("обществ") { return "Обществознание" }
        if has("правов", "юрид", "законодат") { return "ПОПД" }
        if has("философ") { return "Философия" }
        if has("психолог", "общени", "этик") { return "ПсихОбщен" }
        if has("финанс") { return "ФинГрамота" }
        if has("эконом") { return "Экономика" }
        if has("маркетинг") { return "Маркетинг" }
        if has("предпринимат", "бухгалт", "менеджмент") { return "Предпринимат" }

        if has("жизнедеятельн", "обж", "охран труда") { return "ОБиЗР" }
        if has("медицин") { return "Медицина" }
        if has("график", "графическ") { return "ГрафДизайн" }
        if has("черчени", "дизайн", "инженерн") { return "Дизайн" }
        if has("практик", "производствен", "стажировк") { return "ПроизвПракт.01" }
        if has("проект", "курсов", "диплом", "вкр") { return "Проект" }
        if has("экзамен", "зачет", "консультац", "аттестац") { return "Демоэкзамен" }
        if has("собрани") { return "ОргСобрание" }
        if has("классн час", "куратор") { return "Классный час" }

        return nil
    }

    // MARK: - Названия портала

    static let icons: [String: String] = [
        "Математика": "function",
        "ЭлВышМат": "x.squareroot",
        "ДискрМат": "point.3.connected.trianglepath.dotted",
        "ТеорВер": "percent",
        "ЧислМетоды": "sum",
        "Физика": "atom",
        "Химия": "flask",
        "Биология": "leaf",
        "Астрономия": "moon.stars",
        "История": "clock.arrow.circlepath",
        "ИстТехно": "hourglass",
        "ИсторияТ": "books.vertical",
        "Обществознание": "building.columns",
        "Философия": "brain",
        "РусЯз": "textformat.abc",
        "Литер": "book",
        "АнглЯз": "character.book.closed",
        "АнглЯзПро": "bubble.left.and.text.bubble.right",
        "Физкульт": "figure.run",
        "ОБиЗР": "fire.extinguisher",
        "ЭлДок": "doc.on.doc",
        "ТехДокиРус": "text.document",
        "ФинГрамота": "rublesign.bank.building",
        "Экономика": "banknote",
        "ПОПД": "scroll",
        "Предпринимат": "chart.line.uptrend.xyaxis",
        "ПредпрКлас": "storefront",
        "ПсихОбщен": "brain.head.profile",
        "КритМыш": "lightbulb",
        "ИнжМыш": "gearshape.2",
        "ТРИЗ": "wand.and.sparkles",
        "АктМаст": "theatermasks",
        "ЛичБренд": "person.crop.circle.badge.checkmark",
        "КреативМ": "sparkles",
        "ОКРиУП": "list.clipboard",
        "ВведСпец": "signpost.right",
        "ВВСпец-П": "map",

        "РазработкаПО": "chevron.left.forwardslash.chevron.right",
        "РазработкаПО-1": "laptopcomputer",
        "РазработкаПО-2": "desktopcomputer",
        "РазрПО-П": "wrench.adjustable",
        "ВведениеООП": "square.stack.3d.up",
        "ПрогрC#": "number.square",
        "UnityC#": "cube",
        "Frameworks": "square.3.layers.3d",
        "React": "circle.hexagongrid",
        "АиСД": "arrow.triangle.branch",
        "АиСД-2": "arrow.triangle.merge",
        "Hardware": "memorychip",
        "ОперСистемы": "terminal",
        "КомпСети": "network",
        "СУБД": "cylinder.split.1x2",
        "СУБД-1": "cylinder",
        "СУБД-2": "externaldrive",
        "СУБД-проектирование": "tablecells",
        "ИнфоБез": "lock.shield",
        "ОсновыML": "cpu",
        "АрхПаттерны": "checkerboard.rectangle",
        "ПарадигмыПроект": "compass.drawing",
        "UML": "flowchart",
        "УчПроект": "curlybraces",
        "УчПроект02": "doc.badge.gearshape",
        "Микросервисы": "square.split.2x2",
        "ИнтегрПО": "puzzlepiece.extension",
        "BE-Production": "externaldrive.connected.to.line.below",
        "Тестирование": "ladybug",
        "ТестИнтерф": "checkmark.rectangle",
        "РазрИнтерф": "rectangle.and.pencil.and.ellipsis",
        "ИнстРазрИнтерф": "wrench.and.screwdriver",
        "РазрИгрИнтерф": "dpad",
        "ИТ-инфр-проект": "server.rack",
        "ИТ-инфр-разв": "cable.connector",
        "ИТ-инфр-экспл": "gauge.with.dots.needle.67percent",

        "Веб-Дизайн": "globe",
        "ГрафДизайн": "beziercurve",
        "ДизИнтерфейсов": "rectangle.3.group",
        "ДизДиджитал": "ipad.and.iphone",
        "ДизМедиа": "photo.on.rectangle.angled",
        "СтилиДизайн": "swatchpalette",
        "Композиция": "rectangle.split.3x3",
        "Колористика": "paintpalette",
        "2D-КомпГраф": "square.on.circle",
        "3D-КомпГраф": "cube.transparent",
        "3D-Интерфейсы": "rotate.3d",
        "UX/UI дизайн": "rectangle.and.hand.point.up.left",
        "АналитикаUX": "chart.pie",

        "GameDev-2(1)": "gamecontroller",
        "GameDev-2(2)": "arcade.stick.console",
        "GameDev-3(3)": "arcade.stick",
        "GameDev-практ": "l.joystick",
        "ИгроДев": "r.joystick",
        "ИгроМех": "dice",
        "РазработкаИгрП": "puzzlepiece",
        "СопрИгрПрод": "shippingbox",
        "РевьюКода": "doc.text.magnifyingglass",
        "РевьюИгроКейс2": "magnifyingglass.circle",
        "РевьюИгроКейс3": "binoculars",
        "Маркетинг": "megaphone",

        "УпрИТ-проект": "list.bullet.clipboard",
        "ВидыПроект": "rectangle.stack",
        "ФормПроекта": "doc.badge.plus",
        "ГруппаПроекта": "person.3.sequence",
        "ЭтапыПроекта": "list.number",
        "КейсыПроектов": "folder",
        "ПроектированиеБП": "rectangle.connected.to.line.below",
        "ПроектыБП": "chart.bar.doc.horizontal",
        "ПсихологияБП": "person.2.circle",
        "ПсихоПроекта": "person.2.wave.2",
        "МаркетингПМ": "target",
        "ПродРазр": "app.badge",
        "ОтрасПР": "suitcase",
        "Предприятия": "building.2",

        "Проект": "doc.text",
        "Проект-3": "doc.on.clipboard",
        "ПрофПредмет": "star.square",
        "ПроизвПракт.01": "briefcase",
        "УчПракт03": "hammer",
        "УчПракт04": "screwdriver",
        "УчПракт06": "wrench",
        "УчПракт.БП": "hammer.circle",
        "УчПракт": "hammer.fill",
        "АлгоТруд-3": "person.text.rectangle",
        "Демоэкзамен": "checkmark.seal",
        "Предзащита": "rectangle.inset.filled.and.person.filled",
        "Нормоконтроль": "text.line.magnify",
        "В.Сборы": "helmet",
        "Буткемп": "tent",
        "Выставка": "photo.artframe",
        "ФорумБудущего": "bubble.left.and.bubble.right",
        "ОргСобрание": "calendar.and.person",
        "Подгруппы": "list.bullet.indent",
        "Подгруппы-1к": "1.square",
        "Подгруппы-2к": "2.square",
        "Подгруппы-3к": "3.square",

        "Мобильная разработка": "iphone",
        "География": "globe.europe.africa",
        "Медицина": "cross.case",
        "Дизайн": "paintbrush.pointed",
        "Классный час": "person.3",
    ]

    // MARK: - Другие написания предметов

    static let aliases: [String: String] = [
        "Литература": "Литер",
        "АнлгЯзПро": "АнглЯзПро",
        "Физкультура": "Физкульт",
        "ВВСпец": "ВведСпец",
        "ОперСистем": "ОперСистемы",
        "АрхПаттерны3": "АрхПаттерны",
        "ПарадПроекта": "ПарадигмыПроект",
        "ИнтегрПО2": "ИнтегрПО",
        "ТестИнтерфейс": "ТестИнтерф",
        "ТестИнтерфейсов": "ТестИнтерф",
        "ТестUI": "ТестИнтерф",
        "РазрUI": "РазрИнтерф",
        "ИПИР": "ИнстРазрИнтерф",
        "Проект-ИТ-ИНФ": "ИТ-инфр-проект",
        "Развер-ИТ-ИНФ": "ИТ-инфр-разв",
        "Экспл-ИТ-ИНФ": "ИТ-инфр-экспл",
        "ВебДизайн": "Веб-Дизайн",
        "ИнтерфДиз": "ДизИнтерфейсов",
        "ДигиДиз": "ДизДиджитал",
        "СтилиДиз": "СтилиДизайн",
        "2D-Граф": "2D-КомпГраф",
        "3D-Граф": "3D-КомпГраф",
        "3D-Интерф": "3D-Интерфейсы",
        "ИгроМаркетинг": "Маркетинг",
        "КейсыПроекта": "КейсыПроектов",
    ]
}
