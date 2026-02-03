import 'package:flutter/material.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';
import 'package:flutter_ar/features/auth/domain/services/firestore_service.dart';
import 'admin_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminTicketsScreen extends StatelessWidget {
  const AdminTicketsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirestoreService _firestoreService = FirestoreService(
      currentUid: FirebaseAuth.instance.currentUser?.uid,
    );
    final String? adminUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения пользователей')
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: _firestoreService.getAllTickets(),
        builder: (context, snapshot) {
          // === ОШИБКА ===
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Ошибка загрузки',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Назад'),
                    ),
                  ],
                ),
              ),
            );
          }

          // === ЗАГРУЗКА ===
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 3),
            );
          }

          // === ДАННЫЕ ПОЛУЧЕНЫ ===
          final List<Ticket> allTickets = snapshot.data!;
          final List<Ticket> userTickets =
              allTickets.where((ticket) => ticket.userUid != adminUid).toList();

          // === ПУСТОЙ СПИСОК ===
          if (userTickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет обращений',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Пользователи ещё не отправляли сообщения',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // === СПИСОК ТИКЕТОВ ===
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userTickets.length,
            itemBuilder: (context, index) {
              final ticket = userTickets[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    ticket.theme,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        ticket.userEmail,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(ticket.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ticket.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_unreadCountForAdmin(ticket) > 0) 
                        _buildAdminUnreadBadge(ticket),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminChatScreen(ticket: ticket),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminUnreadBadge(Ticket ticket) {
    final count = _unreadCountForAdmin(ticket);
    if (count == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  int _unreadCountForAdmin(Ticket t) {
    final lastRead = t.lastReadByAdmin;

    int count = 0;

    if (t.message.trim().isNotEmpty) {
      if (lastRead == null || t.createdAt.compareTo(lastRead) > 0) {
        count++;
      }
    }

    for (final msg in t.userMessages) {
      if (lastRead == null || msg.timestamp.compareTo(lastRead) > 0) {
        count++;
      }
    }

    return count;
  }

  // === Вспомогательная функция: цвет статуса ===
  Color _getStatusColor(String status) {
    switch (status) {
      case 'на рассмотрении':
        return Colors.orange;
      case 'в обработке':
        return Colors.blue;
      case 'принято':
        return Colors.green;
      case 'отклонено':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}