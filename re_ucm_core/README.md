# re_ucm_core

Pure-Dart ядро и контрактная база ReUltimateCopyManager.

Пакет не зависит от Flutter и содержит общие интерфейсы порталов, схемы динамических настроек, модели прогресса и интеграцию с AST библиотеки [dart_book](https://github.com/BooksFine/dart_book).

## Основные компоненты

- **`Portal` и `PortalService`** (`lib/models/portal/`): интерфейсы для интеграции с литературными ресурсами.
- **Интеграция с `dart_book`**: работа с метаданными (`BookMetadata`), структурой книги (`BookContent`) и загрузкой ресурсов (`BookResourceResolver`).
- **Схемы настроек** (`lib/models/portal/portal_settings_schema.dart`): декларативное описание экранов настроек и авторизации порталов (`PortalSettingItem`).
- **Модели прогресса** (`lib/models/progress.dart`): отслеживание стадий скачивания и пофайловый статус загрузки изображений (`ImageDownloadTask`).
- **Логирование** (`lib/logger.dart`): глобальный логгер.

## Добавление нового портала

1. Реализовать `PortalSettings` для настроек модуля.
2. Реализовать `PortalService<TSettings>` для работы с API ресурса и конвертации данных в структуры `dart_book`.
3. Реализовать `Portal<TSettings>` с метаданными ресурса (url, имя, код, логотип).