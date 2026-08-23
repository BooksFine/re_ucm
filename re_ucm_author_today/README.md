# re_ucm_author_today

Модуль поддержки портала [Author.Today](https://author.today) для ReUltimateCopyManager.

Реализует интерфейсы `Portal` и `PortalService` из [re_ucm_core](../re_ucm_core/) с формированием структуры книги через [dart_book](https://github.com/BooksFine/dart_book).

## Особенности

- **Авторизация**: через встроенный браузер (перехват cookies) или прямой ввод Bearer-токена. Автоматическое обновление токена при истечении сессии.
- **Расшифровка глав**: расшифровка защищенного текста (AES-128-CBC + PKCS7).
- **Метаданные**: обработка авторов и соавторов, жанров, циклов и оригиналов обложек.
- **Загрузка ресурсов**: встроенный резолвер для картинок в главах.

## Сборка

```bash
dart run build_runner build --delete-conflicting-outputs
```
