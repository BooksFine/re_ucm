import 'package:flutter/material.dart';

import '../../../core/navigation/router_delegate.dart';
import '../../../core/ui/constants.dart';
import '../../common/utils/uri_from_url.dart';
import '../../common/widgets/btn.dart';
import '../../portals/domain/portal_factory.dart';

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

  bool isEmpty = true;

  void onChanged(String value) {
    final newIsEmpty = value.isEmpty;
    if (isEmpty != newIsEmpty) {
      isEmpty = newIsEmpty;
      setState(() {});
    }
  }

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
              suffixIcon: isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: ColorScheme.of(context).secondary,
                      ),
                      onPressed: () {
                        textController.clear();
                        isEmpty = true;
                        setState(() {});
                      },
                    ),
            ),
            validator: (url) {
              try {
                final uri = uriFromUrl(url!);
                PortalFactory.fromUrl(uri).service.getIdFromUrl(uri);
                return null;
              } catch (e) {
                return 'Введите корректную ссылку';
              }
            },
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: appPadding),
        ElevatedButton1(func: goButtonFunc, child: const Text('Go')),
      ],
    );
  }

  void goButtonFunc() {
    if (formKey.currentState!.validate()) {
      var url = textController.text;
      final uri = uriFromUrl(url);
      final portal = PortalFactory.fromUrl(uri);

      focus.unfocus();

      Nav.book(portal.code, portal.service.getIdFromUrl(uri));
    }
  }
}
