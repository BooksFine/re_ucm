<div align="center">
  <img src="https://github.com/user-attachments/assets/95272928-e4a2-4a32-85ca-0f0f8be88144" width="400">
</div>

# ReUltimateCopyManager

Кроссплатформенный загрузчик книг с различных ресурсов.

Все действия происходят на устройстве, без необходимости отправлять на сторонние сервера свои учётные данные.

[ Реинкарнация JS юзерскрипта Ultimate Copy Manager, созданного для Telegram-канала [BooksFine](https://t.me/BookFine) ]

### Основные функции:
* Загрузка бесплатных и купленных книг у которых запрещено скачивание в различных форматах
* Быстрое открытие книги через системное меню "Поделиться"
* Встроенный браузер для открытия книг и авторизации в сервисах
* OTA-обновления

### Поддерживаемые форматы:
 * fb2

### Поддерживаемые ресурсы:
<div style="display: flex; overflow-x: auto;">
  <a href="https://author.today" target="_blank">
        <img src="https://github.com/user-attachments/assets/4c2232d2-a3ee-41f5-a8bb-2ac0f6f64223" alt="Author Today" width="100" >
  </a>
</div>

### Требования Windows версии:
* Windows 10 (1803) и выше
* Не вырезанные Microsoft Edge и WebView2 

 
 ## Вы можете самостоятельно добавить поддержку нужного вам ресурса в проект.

 Проект имеет модульную структуру, все основные модели и интерфейсы вынесены в библиотеку [re_ucm_core](https://github.com/BooksFine/re_ucm_core).

 Для модуля сервиса необходимо:
 * имплементировать [интерфейс Portal](https://github.com/BooksFine/re_ucm_core/blob/main/lib/models/portal/portal.dart)
 * зарегистрировать портал в [di.dart](https://github.com/BooksFine/re_ucm/blob/main/lib/core/di.dart)

Модуль Author.Today: [re_ucm_author.today](https://github.com/BooksFine/re_ucm_author_today)
