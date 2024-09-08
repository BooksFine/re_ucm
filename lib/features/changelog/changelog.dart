class Changelog {
  final String title;
  final String date;
  final String content;

  const Changelog({
    required this.title,
    required this.date,
    required this.content,
  });
}

const changelog = [
  Changelog(
    title: 'Релиз 2.1.0',
    date: '28.09.2024',
    content: '''•   Добавлена поддержка litnet.com
•   Добавлена проверка обновлений''',
  ),
  Changelog(
    title: 'Релиз 2.0.0',
    date: '10.09.2024',
    content: '''•   Переработан дизайн главного экрана.
•   Добавлен список недавно открытых книг
•   Добавлен вход по токену
•   Исправлена работа author.today через впн
•   Добавлены обработка ошибок и логирование
•   Улучшена модульность проекта
•   Вёрстка адаптирована под ПК и планшеты
•   Выпущен тестовый ПК релиз
•   Добавлен ченжлог (который вы читаете прямо сейчас xD)
•   Исправлено задваивание файлов в кэше
•   Добавлена информация о книге при отправке
•   Добавлены баги''',
  ),
  Changelog(
    title: 'Релиз 1.0.0',
    date: '28.12.2023',
    content: '•   Тестовый перезапуск UCM',
  ),
];
