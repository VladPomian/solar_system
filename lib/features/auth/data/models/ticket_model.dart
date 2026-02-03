import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final Timestamp timestamp;
  final bool isFromAdmin;

  Message({
    required this.text,
    required this.timestamp,
    required this.isFromAdmin,
  });

  factory Message.fromFirestore(Map<String, dynamic> data,
      {required bool isFromAdmin}) {
    return Message(
      text: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isFromAdmin: isFromAdmin,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'timestamp': timestamp,
    };
  }
}

class Ticket {
  final String id;
  final String userUid;
  final String userEmail;
  final String theme;
  final String message;
  final String status;
  final Timestamp createdAt;
  final List<Message> adminMessages;
  final List<Message> userMessages;
  final bool canUserReply;
  final Timestamp? lastReadByUser;
  final Timestamp? lastReadByAdmin;

  Ticket({
    required this.id,
    required this.userUid,
    required this.userEmail,
    required this.theme,
    required this.message,
    required this.status,
    required this.createdAt,
    this.adminMessages = const [],
    this.userMessages = const [],
    this.canUserReply = false,
    this.lastReadByUser,
    this.lastReadByAdmin,
  });

  factory Ticket.fromFirestore(String id, Map<String, dynamic> data) {
    return Ticket(
      id: id,
      userUid: data['userUid'] ?? 'Пользователь (без email)',
      userEmail: data['userEmail'] ?? '',
      theme: data['theme'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'на рассмотрении',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      adminMessages: (data['adminMessages'] as List<dynamic>?)
              ?.map((m) => Message.fromFirestore(m as Map<String, dynamic>,
                  isFromAdmin: true))
              .toList() ??
          [],
      userMessages: (data['userMessages'] as List<dynamic>?)
              ?.map((m) => Message.fromFirestore(m as Map<String, dynamic>,
                  isFromAdmin: false))
              .toList() ??
          [],
      canUserReply: data['canUserReply'] ?? false, 
      lastReadByUser: data['lastReadByUser'] as Timestamp?,
      lastReadByAdmin: data['lastReadByAdmin'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userUid': userUid,
      'theme': theme,
      'message': message,
      'status': status,
      'createdAt': createdAt,
      'adminMessages': adminMessages.map((m) => m.toFirestore()).toList(),
      'userMessages': userMessages.map((m) => m.toFirestore()).toList(),
      'canUserReply': canUserReply,
      if (lastReadByUser != null) 'lastReadByUser': lastReadByUser,
      if (lastReadByAdmin != null) 'lastReadByAdmin': lastReadByAdmin,
    };
  }

  List<Message> get allMessages {
    return [
      ...adminMessages,
      ...userMessages,
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<Message> get displayMessages {
    final initial = Message(
      text: message,
      timestamp: createdAt,
      isFromAdmin: false,
    );

    return [initial, ...allMessages]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}