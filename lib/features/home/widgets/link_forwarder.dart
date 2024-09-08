import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../core/navigation/router_delegate.dart';
import '../../common/widgets/btn.dart';
import '../../portals/portal.dart';
import '../../portals/portal_service.dart';

final _key = GlobalKey();

class LinkForwarder extends StatefulWidget {
  LinkForwarder() : super(key: _key);
  @override
  State<LinkForwarder> createState() => _LinkForwarderState();
}

class _LinkForwarderState extends State<LinkForwarder> {
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  final focus = FocusNode();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: formKey,
          child: TextFormField(
            focusNode: focus,
            controller: textController,
            onFieldSubmitted: (_) => goButtonFunc(),
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: appPadding,
                horizontal: appPadding * 2,
              ),
              border: OutlineInputBorder(
                gapPadding: 0,
                borderRadius: BorderRadius.circular(cardBorderRadius),
              ),
            ),
            validator: (url) {
              try {
                final uri = uriFromUrl(url!);
                Portal.fromUrl(uri).service.getIdFromUrl(uri);
                return null;
              } catch (e) {
                return 'Введите корректную ссылку';
              }
            },
          ),
        ),
        const SizedBox(height: appPadding),
        ElevatedButton1(
          func: goButtonFunc,
          child: const Text('Go'),
        ),
      ],
    );
  }

  void goButtonFunc() {
    if (formKey.currentState!.validate()) {
      var url = textController.text;
      final uri = uriFromUrl(url);
      final portal = Portal.fromUrl(uri);

      focus.unfocus();

      Nav.book(portal.code, portal.service.getIdFromUrl(uri));
    }
  }

  Uri uriFromUrl(String url) {
    if (!url.startsWith(RegExp(r'https?://'))) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    return uri;
  }
}
