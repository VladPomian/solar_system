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

  void _sendAdminMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await _firestoreService.addAdminMessage(widget.ticket.id, text);
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