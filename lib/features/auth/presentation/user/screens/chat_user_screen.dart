import 'package:flutter/material.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  static const int maxMessageLength = 1000;

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

          StreamBuilder<Ticket?>(
            stream: _firestoreService.getTicketStream(widget.ticket.id),
            builder: (context, snapshot) {
              final canReply = snapshot.data?.canUserReply ?? widget.ticket.canUserReply;
              if (!canReply) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          TextField(
                            controller: _messageController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 6,
                            minLines: 1,
                            maxLength: maxMessageLength,
                            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                            decoration: const InputDecoration(
                              labelText: 'Ваше сообщение',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 12),
                              alignLabelWithHint: true,
                            ),
                            onSubmitted: (_) => _sendUserMessage(),
                          ),
                          
                          Positioned(
                            top: 0,
                            right: 8,
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _messageController,
                              builder: (context, value, child) {
                                final len = value.text.length;
                                if (len == 0) return const SizedBox.shrink();
                                
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '$len/$maxMessageLength',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.getSecondaryTextColor(context),
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

    final gradient = LinearGradient(
        begin: isMine ? Alignment.topLeft : Alignment.topRight,
        end: isMine ? Alignment.bottomRight : Alignment.bottomLeft,
        colors: [
          bubbleColor,
          bubbleColor.withOpacity(0.2),
        ],
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine) // Только для админа показываем лейбл
              Text(
                'Админ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),
            if (!isMine) const SizedBox(height: 4),
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

    _messageController.clear();

    try {
      await _firestoreService.addUserMessage(widget.ticket.id, text);
    } catch (e) {
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
                _sendUserMessage();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
  }
}