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
- **Linux**: Ubuntu 20.04+ / Debian 11+ (WebKitGTK, GTK 3).
- **macOS**: macOS 10.15 (Catalina) и выше.
- **iOS**: iOS 14.0 и выше (Sideloading).

## Установка <a id="installation"></a>

<details>
<summary><b>🍏 macOS — Инструкция по установке</b></summary>

При первом запуске неподписанного приложения на macOS Gatekeeper может заблокировать открытие.
1. Кликните правой кнопкой мыши (или двумя пальцами по тачпаду) по `ReUCM.app` $\rightarrow$ выберите **Открыть** (*Open*) $\rightarrow$ нажмите **Открыть** в диалоговом окне.
2. Либо перейдите в **Системные настройки** $\rightarrow$ **Конфиденциальность и безопасность** $\rightarrow$ прокрутите вниз до блока **Безопасность** $\rightarrow$ нажмите **Всё равно открыть** (*Open Anyway*).
3. Также можно снять атрибут карантина через Терминал: `xattr -cr /Applications/ReUCM.app`
</details>

<details>
<summary><b>📱 iOS — Инструкция по установке</b></summary>

Файл `.ipa` поставляется для установки методом Sideloading (без подписи Apple Developer):
- Устанавливайте через [AltStore](https://altstore.io), [SideStore](https://sidestore.io), [TrollStore](https://trollstore.app), Scarlet или [Sideloadly](https://sideloadly.io).
</details>

## Разработка

### Структура монорепозитория

- [re_ucm_core](re_ucm_core/) — pure-Dart ядро (интерфейсы `Portal`, схемы настроек, модели прогресса).
- [re_ucm_lib](re_ucm_lib/) — pure-Dart библиотека бизнес-логики (хранилище Sembast, экспорт в изолятах, шаблонизатор путей).
- [re_ucm_author_today](re_ucm_author_today/) — модуль поддержки Author.Today.
- [re_ucm_ficbook](re_ucm_ficbook/) — модуль поддержки Ficbook (Книга Фанфиков).
- [re_ucm_app](re_ucm_app/) — основное Flutter-приложение (Android, Windows, Linux, macOS).

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