<div align="center">
  <img src="https://github.com/user-attachments/assets/95272928-e4a2-4a32-85ca-0f0f8be88144" width="400">

  # ReUltimateCopyManager

  Кроссплатформенный загрузчик книг с различных ресурсов.

  Все действия происходят на устройстве, без отправки учетных данных на сторонние сервера.

  [![GitHub Release](https://img.shields.io/github/v/release/BooksFine/re_ucm?label=Скачать%20релиз&logo=github)](https://github.com/BooksFine/re_ucm/releases/latest)
  [![Telegram](https://img.shields.io/badge/Telegram-ReUCM-2CA5E0?logo=telegram&logoColor=white)](https://t.me/UltimateCopyManager)
  [![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

  [ Реинкарнация JS юзерскрипта Ultimate Copy Manager, созданного для Telegram-канала [BooksFine](https://t.me/BookFine) ]
</div>

## Основные функции

- Загрузка бесплатных и купленных книг с запретом на скачивание.
- Поддерживаемые форматы: `fb2`, `fb2.zip`, `epub` (на базе собственной библиотеки [dart_book](https://github.com/BooksFine/dart_book)).
- Настройка шаблона названия файла и пути сохранения.
- Встроенный браузер для открытия книг и авторизации.
- Быстрое открытие книги через системное меню «Поделиться» (Android).
- Список недавних книг.
- Подробный прогресс загрузки изображений.
- OTA-обновления со списком изменений.
- *(В планах)* CLI-версия для терминала и скриптов.

## Поддерживаемые ресурсы

- [Author.Today](https://author.today)
- [Ficbook (Книга Фанфиков)](https://ficbook.net)

## Платформы и требования

- **Android**: 7.0 и выше.
- **Windows**: Windows 10 (1803) и выше, WebView2 (Microsoft Edge).

## Разработка

### Структура монорепозитория

- [re_ucm_core](re_ucm_core/) — pure-Dart ядро (интерфейсы `Portal`, схемы настроек, модели прогресса).
- [re_ucm_lib](re_ucm_lib/) — pure-Dart библиотека бизнес-логики (хранилище Sembast, экспорт в изолятах, шаблонизатор путей).
- [re_ucm_author_today](re_ucm_author_today/) — модуль поддержки Author.Today.
- [re_ucm_ficbook](re_ucm_ficbook/) — модуль поддержки Ficbook (Книга Фанфиков).
- [re_ucm_app](re_ucm_app/) — основное Flutter-приложение (Android, Windows).

### Сборка и запуск

```bash
# Получение зависимостей во всем воркспейсе
flutter pub get

# Генерация кода (MobX, Freezed, Retrofit)
dart run build_runner build -d

# Запуск приложения
cd re_ucm_app
flutter run
```

### Добавление нового ресурса

Все основные интерфейсы находятся в [re_ucm_core/](re_ucm_core/).

Для добавления модуля сервиса необходимо:

1. Реализовать интерфейсы `Portal` и `PortalService` из `re_ucm_core`, используя `dart_book`.
2. Зарегистрировать портал в `PortalFactory.registerAll([...])` в [re_ucm_app/lib/core/di.dart](re_ucm_app/lib/core/di.dart).