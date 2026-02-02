import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/core/theme/app_theme.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';

class AdminChatScreen extends StatefulWidget {
  final Ticket ticket;
  const AdminChatScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final FirestoreService _firestoreService;
  final _messageController = TextEditingController();
  late String _selectedStatus;

  _AdminChatScreenState()
      : _firestoreService = FirestoreService(
          currentUid: FirebaseAuth.instance.currentUser?.uid,
        );

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticket.status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket.theme)),
      body: Column(
        children: [
          _buildStatusDropdown(),
          _buildReplyCheckbox(),
          Expanded(child: _buildMessagesStream()),
          _buildInputField(),
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
        final canReply =
            snapshot.data?.canUserReply ?? widget.ticket.canUserReply;
        return CheckboxListTile(
          title: const Text('Разрешить пользователю отвечать'),
          value: canReply,
          onChanged: (value) =>
              _firestoreService.setCanUserReply(widget.ticket.id, value!),
        );
      },
    );
  }

  Widget _buildMessagesStream() {
    return StreamBuilder<Ticket?>(
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
    );
  }

  Widget _buildMessageBubble(Message msg) {
    final isMine = msg.isFromAdmin;
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
              isMine ? 'Админ' : 'Пользователь',
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

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Ответ админа'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (_messageController.text.isEmpty) return;
              final text = _messageController.text;
              _messageController.clear();
              try {
                await _firestoreService.addAdminMessage(widget.ticket.id, text);
              } catch (e) {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Ошибка'),
                      content: Text('Не удалось отправить сообщение:\n$e'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}