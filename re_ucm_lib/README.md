# re_ucm_lib

Pure-Dart библиотека бизнес-логики ReUltimateCopyManager.

Используется как во Flutter-приложении (`re_ucm_app`), так и в будущей CLI-версии (`re_ucm_cli`).

## Основные модули

- **`BookExporter`** (`lib/exporters/`): двухэтапная подготовка и сборка книг в отдельном `Isolate` через энкодеры [dart_book](https://github.com/BooksFine/dart_book) (`fb2`, `fb2.zip`, `epub`).
- **`SettingsService` / `SettingsStorage`** (`lib/settings/`): хранилище настроек приложения и сессий порталов на базе Sembast IO.
- **Шаблонизатор путей** (`lib/settings/domain/`): `PathTemplate` и `TemplateFormatter` с плейсхолдерами `Название`, `Серия`, `Номер в серии`, `Авторы`, `Портал`.
- **`RecentBooksService`** (`lib/recent_books/`): реактивное управление историей недавних книг (MobX + Sembast).
- **`PortalFactory` / `PortalSession`** (`lib/portals/`): реестр порталов и реактивные сессии с автосохранением настроек.

## Пример использования (для ботов и CLI)

Библиотеку можно использовать как независимый движок. Пример скачивания книги:

```dart
import 'package:re_ucm_lib/re_ucm_lib.dart';
import 'package:re_ucm_author_today/re_ucm_author_today.dart';

void main() async {
  // 1. Инициализация порталов
  PortalFactory.registerAll([AuthorToday()]);
  final portal = PortalFactory.fromCode('author_today');

  // 2. Получение данных книги (через PortalService)
  final service = portal.createService();
  final metadata = await service.getBookMetadata('https://author.today/work/123');
  final content = await service.getBookContent('https://author.today/work/123');
  final resolver = service.getResourceResolver();

  // 3. Подготовка и скачивание ресурсов
  final result = await BookExporter.resolveBook(
    metadata: metadata,
    content: content,
    resourceResolver: resolver,
    onProgress: (progress) => print('Прогресс загрузки: ${progress.stage}'),
  );

  // 4. Сборка в нужный формат (в отдельном Isolate)
  final bytes = await BookExporter.encode(
    book: result.book,
    format: SaveFormat.fb2Zip,
  );
  
  // Дальше можно сохранить bytes в файл или отправить юзеру
}
```

## Сборка

```bash
dart run build_runner build --delete-conflicting-outputs
```
