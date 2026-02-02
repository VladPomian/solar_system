import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';

class ChatUserScreen extends StatefulWidget {
  final Ticket ticket;
  const ChatUserScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  _ChatUserScreenState createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final FirestoreService _firestoreService =
      FirestoreService(currentUid: FirebaseAuth.instance.currentUser?.uid);
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket.theme)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Ticket?>(
              stream: _firestoreService.getTicketStream(widget.ticket.id),
              builder: (context, snapshot) {
                final ticket = snapshot.data ?? widget.ticket;
                final messages = ticket.displayMessages;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),

          // ---- Поле ввода (только если canUserReply == true) ----
          StreamBuilder<Ticket?>(
            stream: _firestoreService.getTicketStream(widget.ticket.id),
            builder: (context, snapshot) {
              final canReply =
                  snapshot.data?.canUserReply ?? widget.ticket.canUserReply;
              if (!canReply) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Ваше сообщение',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendUserMessage,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg) {
    final isMine = !msg.isFromAdmin;
    final bubbleColor = AppTheme.getChatBubbleColor(context, isMine);
    final textColor = AppTheme.getChatTextColor(context, isMine);
    final secondaryColor = AppTheme.getChatSecondaryTextColor(context, isMine);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isMine ? 'Вы' : 'Админ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.text,
              style: TextStyle(color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              msg.timestamp.toDate().toString().substring(0, 16),
              style: TextStyle(fontSize: 10, color: secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  // Отправка сообщения пользователем
  void _sendUserMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Оптимистически очищаем поле сразу (чтобы пользователь видел, что «отправил»)
    _messageController.clear();

    try {
      await _firestoreService.addUserMessage(widget.ticket.id, text);

      // Если всё ок — ничего дополнительно не показываем
    } catch (e) {
      // Возвращаем текст обратно, чтобы пользователь мог повторить попытку
      _messageController.text = text;

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red, size: 48),
          title: const Text('Не удалось отправить сообщение'),
          content: SelectableText(
            e.toString(),
            style: const TextStyle(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Понятно'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _sendUserMessage(); // попробовать ещё раз
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
  }
}