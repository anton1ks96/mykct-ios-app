<div align="center">

<img src="docs/banner.png" alt="МойКЦТ" width="820"/>

# МойКЦТ

**Расписание, посещаемость и оценки Колледжа Цифровых Технологий - в одном приложении**

[![App Store](https://img.shields.io/badge/App_Store-загрузить-0D96F6?style=for-the-badge&logo=appstore&logoColor=white)](https://apps.apple.com/app/id6752833964)

![Swift](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Liquid_Glass-0D96F6?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-18.0%2B-000000?logo=apple&logoColor=white)
![watchOS](https://img.shields.io/badge/watchOS-26.0%2B-000000?logo=apple&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

</div>

---

## Что умеет

| | |
|---|---|
| **Расписание** | Неделя целиком, три дня или один - на выбор. Пары нарисованы на временной сетке: высота карточки равна длительности, идущая пара подсвечена и показывает, сколько осталось |
| **Своя группа** | Группа, подгруппа, профиль и английская группа - расписание сразу подстраивается под конкретного студента |
| **Детали пары** | Тема, преподаватель, кабинет и подгруппы - по нажатию на карточку |
| **Посещаемость** | Календарь месяца с отметками по дням: был, уважительная, неуважительная |
| **Стрик** | Сколько дней подряд без пропусков - прямо в шапке расписания |
| **Успеваемость** | Оценки по каждой работе и средний балл по предмету |
| **Рейтинг** | Место на курсе, вместо имён - случайные псевдонимы |
| **Виджеты** | Текущая и следующая пара на домашнем экране, работают без запуска приложения |
| **Apple Watch** | Расписание на запястье и расширения на циферблате, снимок приходит с iPhone |
| **Темы** | Светлая, тёмная и системная. Свой шрифт, свои иконки предметов, Liquid Glass на iOS 26 |

## Стек

- **Swift 6** + **SwiftUI** + **Observation**, строгая конкурентность, `MainActor` по умолчанию
- **MVVM** без DI-контейнеров: зависимости собираются руками в `AppDependencies`
- **Alamofire** для сети, обновление токенов - single-flight в `actor`
- **WidgetKit** и **WatchConnectivity** для виджетов и часов
- **Firebase Crashlytics** и **MetricKit** для отчётов о сбоях
- Юнит-тесты на **Swift Testing**, зависимости подменяются протокольными фейками

<div align="center">
<br/>
<a href="https://anton1ks96.github.io/mykct-ios-app/">Сайт</a> · <a href="https://anton1ks96.github.io/mykct-ios-app/privacy.html">Конфиденциальность</a>
<br/><br/>
Сделано для студентов КЦТ
</div>
