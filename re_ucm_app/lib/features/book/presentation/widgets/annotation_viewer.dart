import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AnnotationViewer extends StatelessWidget {
  const AnnotationViewer({super.key, required this.annotation});

  final String annotation;

  @override
  Widget build(BuildContext context) {
    return HTML.toRichText(
      context,
      annotation,
      linksCallback: (link) =>
          launchUrlString(link, mode: LaunchMode.externalApplication),
      overrideStyle: {
        'a': TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.none,
        ),
      },
      defaultTextStyle: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
