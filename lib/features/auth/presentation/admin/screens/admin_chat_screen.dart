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

  static const int maxMessageLength = 1000;

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
            bottomRight: Radius.circular(0),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(0),
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
                  labelText: 'Ответ админа',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 12),
                  alignLabelWithHint: true,
                ),
                onSubmitted: (_) {},
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