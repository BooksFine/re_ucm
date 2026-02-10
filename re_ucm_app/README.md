<div align="center">
  <img src="https://github.com/user-attachments/assets/95272928-e4a2-4a32-85ca-0f0f8be88144" width="400">
</div>

# ReUltimateCopyManager

Кроссплатформенный загрузчик книг с различных ресурсов.

Все действия происходят на устройстве, без необходимости отправлять на сторонние сервера свои учетные данные.

[ Реинкарнация JS юзерскрипта Ultimate Copy Manager, созданного для Telegram-канала [BooksFine](https://t.me/BookFine) ]

## Основные функции

- Загрузка бесплатных и купленных книг, у которых запрещено скачивание, в различных форматах.
- Быстрое открытие книги через системное меню "Поделиться".
- Встроенный браузер для открытия книг и авторизации в сервисах.
- OTA-обновления.

## Поддерживаемые форматы

- fb2

## Поддерживаемые ресурсы

<div style="display: flex; overflow-x: auto;">
  <a href="https://author.today" target="_blank">
    <img src="https://github.com/user-attachments/assets/4c2232d2-a3ee-41f5-a8bb-2ac0f6f64223" alt="Author Today" width="100">
  </a>
</div>

## Требования Windows версии

- Windows 10 (1803) и выше.
- Не вырезанные Microsoft Edge и WebView2.

## Разработка

### Структура монорепозитория

- [re_ucm_app](../re_ucm_app/) - основное приложение.
- [re_ucm_core](../re_ucm_core/) - общие модели, интерфейсы и UI-компоненты.
- [re_ucm_author_today](../re_ucm_author_today/) - модуль поддержки Author.Today. С ростом числа модулей, они будут вынесены в отдельный каталог


### Добавление нового ресурса

Проект имеет модульную структуру, все основные модели и интерфейсы вынесены в библиотеку [re_ucm_core/](../re_ucm_core/).

Для модуля сервиса необходимо:

- Имплементировать интерфейс `Portal` из [re_ucm_core/lib/models/portal/portal.dart](../re_ucm_core/lib/models/portal/portal.dart).
- Зарегистрировать портал в [re_ucm_app/lib/core/di.dart](lib/core/di.dart).
