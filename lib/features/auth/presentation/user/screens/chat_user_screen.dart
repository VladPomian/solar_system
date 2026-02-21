import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';
import 'package:flutter_ar/features/auth/presentation/widgets/chat_bubble.dart';
import 'package:flutter_ar/features/auth/presentation/widgets/chat_input_field.dart';

class ChatUserScreen extends StatefulWidget {
  final Ticket ticket;
  const ChatUserScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<ChatUserScreen> createState() => _ChatUserScreenState();
}

class _ChatUserScreenState extends State<ChatUserScreen> {
  final FirestoreService _firestoreService = 
      FirestoreService(currentUid: FirebaseAuth.instance.currentUser?.uid);
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(widget.ticket.id)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) return;

      final data = doc.data()!;
      final currentLastRead = data['lastReadByUser'] as Timestamp?;

      final adminMessages = (data['adminMessages'] as List<dynamic>?)?.map((e) {
        return Message.fromFirestore(e as Map<String, dynamic>, isFromAdmin: true);
      }).toList() ?? [];

      final hasUnread = adminMessages.any(
        (m) => currentLastRead == null || m.timestamp.compareTo(currentLastRead) > 0,
      );

      if (hasUnread) {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(widget.ticket.id)
            .update({
          'lastReadByUser': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Ошибка markAsRead (user): $e');
    }
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

                if (ticket.adminMessages.isNotEmpty) {
                  final latestAdminMsg = ticket.adminMessages.last;
                  final lastRead = ticket.lastReadByUser;

                  if (lastRead == null || latestAdminMsg.timestamp.compareTo(lastRead) > 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _markAsRead();
                    });
                  }
                }

                final messages = ticket.displayMessages;

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return ChatBubble(
                      msg: msg,
                      isMine: !msg.isFromAdmin,
                      showSenderLabel: !msg.isFromAdmin,
                      senderLabel: !msg.isFromAdmin ? 'Админ' : null,
                      ticket: ticket,
                      isCurrentUserAdmin: false,
                    );
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

              return ChatInputField(
                controller: _messageController,
                labelText: 'Ваше сообщение',
                onSend: _sendUserMessage,
              );
            },
          ),
        ],
      ),
    );
  }

  void _sendUserMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _firestoreService.addUserMessage(widget.ticket.id, text);
      await _markAsRead();
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