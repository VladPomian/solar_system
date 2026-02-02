import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final VoidCallback onSend;
  final bool autofocus;

  static const int maxMessageLength = 1000;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.onSend,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              children: [
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  maxLines: 6,
                  minLines: 1,
                  maxLength: maxMessageLength,
                  buildCounter: (context, {required currentLength, required maxLength, required isFocused}) => null,
                  autofocus: autofocus,
                  decoration: InputDecoration(
                    labelText: labelText,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    alignLabelWithHint: true,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
                Positioned(
                  top: 0,
                  right: 8,
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      final len = value.text.length;
                      if (len == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '$len/$maxMessageLength',
                          style: TextStyle(
                            fontSize: 11,
                            color: len > maxMessageLength * 0.9 
                                ? Colors.red 
                                : AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppTheme.getPrimaryColor(context),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}