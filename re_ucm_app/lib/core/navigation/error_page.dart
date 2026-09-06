import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Простая страница «Не найдено» — замена silent-fail (SizedBox.shrink).
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key, this.code = '404', this.message});

  final String code;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                code,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              const Text('Не найдено'),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
