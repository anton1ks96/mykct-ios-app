//
//  SubjectIcon.swift
//  college-ios-app
//

import Foundation

nonisolated enum SubjectIcon {

    private static let profiles = ["BE", "FE", "GD", "PM", "UI", "SA", "CD"]

    static func symbol(for title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let symbol = lookup(trimmed) { return symbol }
        if let base = withoutProfile(trimmed), let symbol = lookup(base) { return symbol }
        return keyword(for: trimmed)
    }

    private static func lookup(_ title: String) -> String? {
        icons[aliases[title] ?? title]
    }

    private static func withoutProfile(_ title: String) -> String? {
        guard let profile = profiles.first(where: { title.hasSuffix($0) }) else { return nil }
        var base = title.dropLast(profile.count)
        if base.last == "-" || base.last == "." { base = base.dropLast() }
        return base.isEmpty ? nil : String(base)
    }

    private static func keyword(for title: String) -> String {
        let name = title.lowercased().replacingOccurrences(of: "ё", with: "е")
        func has(_ parts: String...) -> Bool { parts.contains { name.contains($0) } }

        if has("физкультур", "физическ", "спорт") { return "figure.run" }

        if (has("баз") && has("данн")) || has("субд", "sql") { return "cylinder.split.1x2" }
        if has("сет", "маршрутизац", "телекоммуникац") { return "network" }
        if has("операционн", "linux", "windows") { return "terminal" }
        if has("дискретн") { return "point.3.connected.trianglepath.dotted" }
        if has("алгоритм", "структур данных") { return "arrow.triangle.branch" }
        if has("тестирован", "отладк", "качеств") { return "ladybug" }
        if has("мобильн", "android", "ios") { return "iphone" }
        if has("веб", "web", "сайт", "html", "фронтенд") { return "globe" }
        if has("криптограф")
            || (has("безопасн") && has("информ", "данн"))
            || (has("защит") && has("информ")) { return "lock.shield" }
        if has("разработ", "программ", "модул", "информатик") {
            return "chevron.left.forwardslash.chevron.right"
        }
        if has("аппаратн", "эвм", "архитектур", "схемотехник") { return "memorychip" }

        if has("русск", "родн") { return "textformat.abc" }
        if has("литератур") { return "book" }
        if has("английск", "иностран", "язык") { return "character.book.closed" }

        if has("статистик", "вероятност") { return "percent" }
        if has("численн метод") { return "sum" }
        if has("высш") && has("матем") { return "x.squareroot" }
        if has("математик", "матем") { return "function" }
        if has("астроном") { return "moon.stars" }
        if has("физик") { return "atom" }
        if has("хими") { return "flask" }
        if has("биолог", "естествознан", "эколог") { return "leaf" }
        if has("географ") { return "globe.europe.africa" }

        if has("истори") { return "clock.arrow.circlepath" }
        if has("обществ") { return "building.columns" }
        if has("правов", "юрид", "законодат") { return "scroll" }
        if has("философ") { return "brain" }
        if has("психолог", "общени", "этик") { return "brain.head.profile" }
        if has("финанс") { return "rublesign.bank.building" }
        if has("эконом") { return "banknote" }
        if has("маркетинг") { return "megaphone" }
        if has("предпринимат", "бухгалт", "менеджмент") { return "chart.line.uptrend.xyaxis" }

        if has("жизнедеятельн", "обж", "охран труда") { return "fire.extinguisher" }
        if has("медицин") { return "cross.case" }
        if has("график") { return "beziercurve" }
        if has("черчени", "дизайн", "инженерн") { return "paintbrush.pointed" }
        if has("практик", "производствен", "стажировк") { return "briefcase" }
        if has("проект", "курсов", "диплом", "вкр") { return "doc.text" }
        if has("экзамен", "зачет", "консультац", "аттестац") { return "checkmark.seal" }
        if has("собрани") { return "calendar.and.person" }
        if has("классн час", "куратор") { return "person.3" }

        return "graduationcap"
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
        "АиСД-2BE": "arrow.triangle.merge",
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
        "РевьюКодаGD": "doc.text.magnifyingglass",
        "РевьюИгроКейс2": "magnifyingglass.circle",
        "РевьюИгроКейс3": "binoculars",
        "МаркетингGD": "megaphone",

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
        "УчПракт.UI": "hammer.fill",
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
        "Тест": "ТестИнтерф",
        "ТестUI": "ТестИнтерф",
        "Разр": "РазрИнтерф",
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
        "ИгроМаркетинг": "МаркетингGD",
        "КейсыПроекта": "КейсыПроектов",
    ]
}
