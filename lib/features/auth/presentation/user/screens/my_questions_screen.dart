import 'package:flutter/material.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';
import 'chat_user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyQuestionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService =
        FirestoreService(currentUid: FirebaseAuth.instance.currentUser?.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои вопросы')),
      body: StreamBuilder<List<Ticket>>(
        stream: _firestoreService.getUserTickets(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                child: ListTile(
                  title: Text(ticket.theme),
                  subtitle: Text(ticket.status),
                  trailing: _buildUnreadBadge(ticket),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatUserScreen(ticket: ticket)),
                  ),
                )
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUnreadBadge(Ticket ticket) {
    final count = _unreadCountForUser(ticket);
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  int _unreadCountForUser(Ticket t) {
    final msgs = t.adminMessages;
    if (msgs.isEmpty) return 0;
    final lastRead = t.lastReadByUser;
    if (lastRead == null) return msgs.length;

    return msgs.where((m) => m.timestamp.compareTo(lastRead) > 0).length;
  }
}