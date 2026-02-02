import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';

class ChatBubble extends StatelessWidget {
  final Message msg;
  final bool isMine;
  final bool showSenderLabel;
  final String? senderLabel;

  const ChatBubble({
    super.key,
    required this.msg,
    required this.isMine,
    this.showSenderLabel = true,
    this.senderLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = AppTheme.getChatBubbleColor(context, isMine);
    final textColor = AppTheme.getChatTextColor(context, isMine);
    final secondaryColor = AppTheme.getChatSecondaryTextColor(context, isMine);

    final gradient = LinearGradient(
      begin: isMine ? Alignment.topLeft : Alignment.topRight,
      end: isMine ? Alignment.bottomRight : Alignment.bottomLeft,
      colors: [bubbleColor, bubbleColor.withOpacity(0.2)],
      stops: const [0.0, 1.0],
    );

    final borderRadius = isMine
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.68,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSenderLabel && senderLabel != null && senderLabel!.isNotEmpty)
                Text(
                  senderLabel!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: secondaryColor,
                  ),
                ),
              if (showSenderLabel && senderLabel != null && senderLabel!.isNotEmpty)
                const SizedBox(height: 4),
              Text(
                msg.text,
                style: TextStyle(color: textColor),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 4),
              Text(
                msg.timestamp.toDate().toString().substring(0, 16),
                style: TextStyle(fontSize: 10, color: secondaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}