import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';
import 'package:flutter_ar/features/auth/presentation/widgets/chat_bubble.dart';
import 'package:flutter_ar/features/auth/presentation/widgets/chat_input_field.dart';

class AdminChatScreen extends StatefulWidget {
  final Ticket ticket;
  const AdminChatScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final FirestoreService _firestoreService = 
      FirestoreService(currentUid: FirebaseAuth.instance.currentUser?.uid);
  final _messageController = TextEditingController();
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('tickets')
          .doc(widget.ticket.id)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) return;

      final data = doc.data()!;
      final currentLastRead = data['lastReadByAdmin'] as Timestamp?;

      final userMessages = (data['userMessages'] as List<dynamic>?)?.map((e) {
        return Message.fromFirestore(e as Map<String, dynamic>, isFromAdmin: false);
      }).toList() ?? [];

      final initialMessageTime = data['createdAt'] as Timestamp?;

      int unreadCount = 0;

      if (initialMessageTime != null && 
          (currentLastRead == null || initialMessageTime.compareTo(currentLastRead) > 0)) {
        unreadCount++;
      }

      unreadCount += userMessages.where((m) => 
        currentLastRead == null || m.timestamp.compareTo(currentLastRead) > 0
      ).length;

      if (unreadCount > 0) {
        await FirebaseFirestore.instance
            .collection('tickets')
            .doc(widget.ticket.id)
            .update({
          'lastReadByAdmin': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Ошибка markAsRead (admin): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket.theme)),
      body: Column(
        children: [
          _buildStatusDropdown(),
          _buildReplyCheckbox(),
          Expanded(
            child: StreamBuilder<Ticket?>(
              stream: _firestoreService.getTicketStream(widget.ticket.id),
              builder: (context, snapshot) {
                final ticket = snapshot.data ?? widget.ticket;

                if (ticket.userMessages.isNotEmpty) {
                  final latestUserMsg = ticket.userMessages.last;
                  final lastRead = ticket.lastReadByAdmin;

                  if (lastRead == null || latestUserMsg.timestamp.compareTo(lastRead) > 0) {
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
                      isMine: msg.isFromAdmin,
                      showSenderLabel: true,
                      senderLabel: msg.isFromAdmin ? 'Админ' : ticket.userEmail,
                      ticket: ticket,
                      isCurrentUserAdmin: true,
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(
            controller: _messageController,
            labelText: 'Ответ админа',
            onSend: _sendAdminMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: _selectedStatus,
        isExpanded: true,
        items: ['на рассмотрении', 'в обработке', 'принято', 'отклонено']
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: (value) {
          setState(() => _selectedStatus = value!);
          _firestoreService.updateTicketStatus(widget.ticket.id, value!);
        },
      ),
    );
  }

  Widget _buildReplyCheckbox() {
    return StreamBuilder<Ticket?>(
      stream: _firestoreService.getTicketStream(widget.ticket.id),
      builder: (context, snapshot) {
        final canReply = snapshot.data?.canUserReply ?? widget.ticket.canUserReply;
        return CheckboxListTile(
          title: const Text('Разрешить пользователю отвечать'),
          value: canReply,
          onChanged: (value) =>
              _firestoreService.setCanUserReply(widget.ticket.id, value!),
        );
      },
    );
  }

  void _sendAdminMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _firestoreService.addAdminMessage(widget.ticket.id, text);
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
                _sendAdminMessage();
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
  }
}