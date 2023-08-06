import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TextInputDialog extends StatelessWidget {
  final String title;
  final String? initialText;
  final TextInputType keyboardType;
  final Function(String, BuildContext) onSubmitted;

  const TextInputDialog({
    required this.title,
    this.initialText,
    required this.keyboardType,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialText);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          TextField(
            autofocus: true,
            controller: controller,
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.bottom,
            onSubmitted: (value) {
              onSubmitted(value, context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.grey[700],
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor:
                Theme.of(context).colorScheme.secondary == Colors.white
                    ? Colors.black
                    : Colors.white,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            onSubmitted(controller.text.trim(), context);
          },
          child: Text(
            AppLocalizations.of(context)!.ok,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }
}

void showTextInputDialog({
  required String title,
  required BuildContext context,
  String? initialText,
  required TextInputType keyboardType,
  required Function(String, BuildContext) onSubmitted,
}) {
  showDialog(
    context: context,
    builder: (BuildContext ctxt) {
      return TextInputDialog(
        title: title,
        initialText: initialText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
      );
    },
  );
}
