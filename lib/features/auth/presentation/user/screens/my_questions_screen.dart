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
      appBar: AppBar(title: Text('Мои вопросы')),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatUserScreen(ticket: ticket)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}