# EffectiveMobileTest

Тестовое задание — приложение для ведения списка задач (ToDo List).

## Возможности

- Просмотр списка задач
- Добавление, редактирование и удаление задач
- Отметка задачи как выполненной
- Поиск по названию и описанию
- При первом запуске задачи загружаются из [dummyjson.com/todos](https://dummyjson.com/todos)
- Данные сохраняются в CoreData и восстанавливаются при повторном запуске

## Стек

- **Язык:** Swift, UIKit (программный UI без Storyboard)
- **Архитектура:** VIPER
- **Хранилище:** CoreData (программная модель)
- **Многопоточность:** GCD (`DispatchQueue`)
- **Тесты:** Swift Testing (14 unit-тестов)

## Структура проекта

```
EffectiveMobileTest/
├── AppDelegate / SceneDelegate
├── CoreData/          — CoreDataStack + NSManagedObject
├── Network/           — NetworkService (URLSession)
├── Resources/         — AppColors (чёрно-зелёная палитра)
└── Modules/
    ├── TodoList/      — список с поиском (VIPER)
    └── TodoDetail/    — создание и редактирование задачи (VIPER)
```

## Запуск

Открыть `EffectiveMobileTest.xcodeproj` в Xcode, выбрать симулятор и нажать Run.
