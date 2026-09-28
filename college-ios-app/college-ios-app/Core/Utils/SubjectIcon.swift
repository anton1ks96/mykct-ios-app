//
//  SubjectIcon.swift
//  college-ios-app
//

import Foundation

nonisolated enum SubjectIcon {

    static func symbol(for title: String) -> String {
        if let symbol = icons[title] { return symbol }

        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed != title, let symbol = icons[trimmed] { return symbol }

        return keyword(for: trimmed)
    }

    private static func keyword(for title: String) -> String {
        let name = title.lowercased().replacingOccurrences(of: "ё", with: "е")
        func has(_ parts: String...) -> Bool { parts.contains { name.contains($0) } }

        if has("физкультур", "физическ", "спорт") { return "figure.run" }

        if (has("баз") && has("данн")) || has("субд", "sql") { return "cylinder.split.1x2" }
        if has("сет", "маршрутизац", "телекоммуникац") { return "network" }
        if has("операционн", "linux", "windows") { return "terminal" }
        if has("алгоритм", "структур данных", "дискретн") { return "arrow.triangle.branch" }
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

        if has("русск", "литератур", "родн") { return "book" }
        if has("английск", "иностран", "язык") { return "character.book.closed" }

        if has("статистик", "вероятност") { return "chart.bar" }
        if has("математик", "матем", "численн метод") { return "function" }
        if has("астроном") { return "moon.stars" }
        if has("физик", "хими") { return "atom" }
        if has("биолог", "естествознан", "эколог") { return "leaf" }
        if has("географ") { return "map" }

        if has("истори") { return "clock.arrow.circlepath" }
        if has("обществ", "правов", "юрид", "законодат") { return "building.columns" }
        if has("психолог", "общени", "этик") { return "brain.head.profile" }
        if has("эконом", "финанс", "предпринимат", "бухгалт", "менеджмент", "маркетинг") {
            return "chart.line.uptrend.xyaxis"
        }

        if has("жизнедеятельн", "обж", "охран труда", "медицин") { return "fire.extinguisher" }
        if has("черчени", "график", "дизайн", "инженерн") { return "paintbrush.pointed" }
        if has("практик", "производствен", "стажировк") { return "briefcase" }
        if has("проект", "курсов", "диплом", "вкр") { return "doc.text" }
        if has("экзамен", "зачет", "консультац", "аттестац") { return "checkmark.seal" }
        if has("классн час", "куратор", "собрани") { return "person.3" }

        return "graduationcap"
    }

    // MARK: - Названия портала

    // Каждому предмету - свой символ; одно значение делят только написания одного предмета
    // в разные годы и его варианты под профили (ТестИнтерф, ТестUI-FE).
    static let icons: [String: String] = [
        // Общие предметы
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
        "Литература": "book",
        "АнглЯз": "character.book.closed",
        "АнглЯзПро": "text.book.closed",
        "АнлгЯзПро": "text.book.closed",
        "Физкульт": "figure.run",
        "Физкультура": "figure.run",
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
        "ВВСпец": "signpost.right",
        "ВВСпец-П": "signpost.right.and.left",

        // Разработка и инфраструктура
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
        "ОперСистем": "terminal",
        "КомпСети": "network",
        "СУБД": "cylinder.split.1x2",
        "СУБД-1": "cylinder",
        "СУБД-2": "externaldrive",
        "СУБД-проектирование": "tablecells",
        "ИнфоБез": "lock.shield",
        "ОсновыML": "cpu",
        "АрхПаттерны": "building.2",
        "АрхПаттерны3": "building.2",
        "ПарадигмыПроект": "compass.drawing",
        "ПарадПроекта": "compass.drawing",
        "UML-BE": "flowchart",
        "UML-FE": "flowchart",
        "УчПроект": "curlybraces",
        "УчПроект.BE": "curlybraces",
        "УчПроект.FE": "curlybraces",
        "УчПроект.PM": "curlybraces",
        "УчПроект02": "doc.badge.gearshape",
        "Микросервисы": "square.split.2x2",
        "МикросервисыBE": "square.split.2x2",
        "МикросервисыFE": "square.split.2x2",
        "ИнтегрПО": "puzzlepiece.extension",
        "ИнтегрПО2": "puzzlepiece.extension",
        "BE-Production": "externaldrive.connected.to.line.below",
        "Тестирование": "ladybug",
        "ТестИнтерф": "checkmark.rectangle",
        "ТестИнтерфейс": "checkmark.rectangle",
        "ТестИнтерфейсов": "checkmark.rectangle",
        "ТестUI": "checkmark.rectangle",
        "ТестUI-FE": "checkmark.rectangle",
        "ТестUI-GD": "checkmark.rectangle",
        "ТестUI-PM": "checkmark.rectangle",
        "РазрИнтерф": "rectangle.and.pencil.and.ellipsis",
        "РазрUI": "rectangle.and.pencil.and.ellipsis",
        "РазрUI-FE": "rectangle.and.pencil.and.ellipsis",
        "РазрUI-GD": "rectangle.and.pencil.and.ellipsis",
        "РазрUI-PM": "rectangle.and.pencil.and.ellipsis",
        "ИнстРазрИнтерф": "wrench.and.screwdriver",
        "ИПИР-FE": "wrench.and.screwdriver",
        "ИПИР-GD": "wrench.and.screwdriver",
        "ИПИР-PM": "wrench.and.screwdriver",
        "ИПИР-UI": "wrench.and.screwdriver",
        "РазрИгрИнтерф": "dpad",
        "ИТ-инфр-проект": "server.rack",
        "Проект-ИТ-ИНФ": "server.rack",
        "ИТ-инфр-разв": "cable.connector",
        "Развер-ИТ-ИНФ": "cable.connector",
        "ИТ-инфр-экспл": "gauge.with.dots.needle.67percent",
        "Экспл-ИТ-ИНФ": "gauge.with.dots.needle.67percent",

        // Дизайн
        "Веб-Дизайн": "globe",
        "ВебДизайн": "globe",
        "ГрафДизайн": "beziercurve",
        "ДизИнтерфейсов": "rectangle.3.group",
        "ИнтерфДиз": "rectangle.3.group",
        "ДизДиджитал": "ipad.and.iphone",
        "ДигиДиз": "ipad.and.iphone",
        "ДизМедиа": "photo.on.rectangle.angled",
        "СтилиДизайн": "swatchpalette",
        "СтилиДиз": "swatchpalette",
        "Композиция": "rectangle.split.3x3",
        "Колористика": "paintpalette",
        "2D-КомпГраф": "square.on.circle",
        "2D-Граф": "square.on.circle",
        "3D-КомпГраф": "cube.transparent",
        "3D-Граф-GD": "cube.transparent",
        "3D-Интерфейсы": "rotate.3d",
        "3D-Интерф": "rotate.3d",
        "UX/UI дизайн": "rectangle.and.hand.point.up.left",
        "АналитикаUX": "chart.pie",

        // Разработка игр
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
        "ИгроМаркетинг": "megaphone",

        // Управление проектами
        "УпрИТ-проект": "list.bullet.clipboard",
        "ВидыПроект": "rectangle.stack",
        "ФормПроекта": "doc.badge.plus",
        "ГруппаПроекта": "person.3.sequence",
        "ЭтапыПроекта": "list.number",
        "КейсыПроектов": "folder",
        "КейсыПроекта": "folder",
        "ПроектированиеБП": "rectangle.connected.to.line.below",
        "ПроектыБП": "chart.bar.doc.horizontal",
        "ПсихологияБП": "person.2.circle",
        "ПсихоПроекта": "person.2.wave.2",
        "МаркетингПМ": "target",
        "ПродРазр": "app.badge",
        "ОтрасПР": "building",
        "Предприятия": "building.2.crop.circle",

        // Проекты, практика и мероприятия
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
}
