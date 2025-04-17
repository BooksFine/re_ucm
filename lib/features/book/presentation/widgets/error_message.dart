import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../book_page_controller.cg.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key, required this.controller});

  final BookPageController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.zero,
      title: const Text('Произошла ошибка'),
      content: Text(
        controller.book.error is DioException &&
                controller.book.error.message is String
            ? controller.book.error.message
            : controller.book.error.toString(),
      ),
      actions: [
        ElevatedButton(
          onPressed: controller.fetch,
          child: const Text('Повторить'),
        ),
      ],
    );
  }
}
