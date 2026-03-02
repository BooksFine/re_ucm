import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../core/ui/constants.dart';
import '../../presentation/settings_controller.cg.dart';

class SaveDirectoryField extends StatefulWidget {
  const SaveDirectoryField({super.key, required this.controller});

  final SettingsController controller;

  @override
  State<SaveDirectoryField> createState() => _SaveDirectoryFieldState();
}

class _SaveDirectoryFieldState extends State<SaveDirectoryField> {
  final saveDirectoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    saveDirectoryController.text = widget.controller.saveDirectory ?? '';
  }

  @override
  void dispose() {
    saveDirectoryController.dispose();
    super.dispose();
  }

  Future<void> onPickSaveDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      saveDirectoryController.text = result;
      widget.controller.updateSaveDirectory(result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        mouseCursor: SystemMouseCursors.click,
        readOnly: true,
        onTap: onPickSaveDirectory,
        controller: saveDirectoryController,
        decoration: InputDecoration(
          visualDensity: VisualDensity.comfortable,
          floatingLabelStyle: TextStyle(
            fontSize: 20,
            color: ColorScheme.of(context).onSurfaceVariant,
          ),
          labelText: 'Папка для сохранения',
          labelStyle: TextStyle(
            color: ColorScheme.of(context).onSurfaceVariant,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: appPadding,
            horizontal: appPadding * 2,
          ),
          border: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: BorderRadius.circular(cardBorderRadius),
          ),
          suffixIcon: Icon(
            Icons.folder_open,
            color: ColorScheme.of(context).onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
