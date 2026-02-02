import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ar/features/auth/data/models/ticket_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? currentUid;

  FirestoreService({this.currentUid});

  Future<void> createTicket(String theme, String message) async {
    if (currentUid == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('tickets').add({
      'userUid': currentUid,
      'userEmail': user.email,
      'theme': theme,
      'message': message,
      'status': 'на рассмотрении',
      'createdAt': FieldValue.serverTimestamp(),
      'adminMessages': [],
      'userMessages': [],
      'canUserReply': false,
    });
  }

  // Остальные методы без изменений
  Stream<List<Ticket>> getUserTickets() {
    if (currentUid == null) return Stream.value([]);
    return _firestore
        .collection('tickets')
        .where('userUid', isEqualTo: currentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ticket.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Ticket>> getAllTickets() {
    return _firestore
        .collection('tickets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Ticket.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Stream<Ticket?> getTicketStream(String ticketId) {
    return _firestore.collection('tickets').doc(ticketId).snapshots().map(
        (doc) => doc.exists ? Ticket.fromFirestore(doc.id, doc.data()!) : null);
  }

  Future<void> updateTicketStatus(String ticketId, String status) async {
    await _firestore
        .collection('tickets')
        .doc(ticketId)
        .update({'status': status});
  }

  Future<void> addAdminMessage(String ticketId, String text) async {
    if (text.isEmpty) return;

    final newMessage = {
      'text': text,
      'timestamp': Timestamp.now(), // ← Используем время с устройства
    };

    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'adminMessages': FieldValue.arrayUnion([newMessage]),
      });
    } catch (e) {
      print('addAdminMessage error: $e');
      rethrow;
    }
  }

  Future<void> addUserMessage(String ticketId, String text) async {
    if (text.isEmpty) return;

    final messageText = text.trim();
    if (messageText.isEmpty) return;

    final docRef = _firestore.collection('tickets').doc(ticketId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception("Тикет не существует");
        }

        final data = snapshot.data()!;
        final currentMessages = List<Map<String, dynamic>>.from(
          data['userMessages'] as List? ?? [],
        );

        currentMessages.add({
          'text': messageText,
          'timestamp': Timestamp.now(),
        });

        transaction.update(docRef, {
          'userMessages': currentMessages,
        });
      });
    } catch (e) {
      print('Ошибка отправки сообщения пользователем: $e');
      rethrow;
    }
  }

  Future<void> setCanUserReply(String ticketId, bool canReply) async {
    await _firestore
        .collection('tickets')
        .doc(ticketId)
        .update({'canUserReply': canReply});
  }
}