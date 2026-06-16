class Message {
  final int? id;
  final String caseId;
  final String userName;
  final String contactInfo;
  final String textMessage;
  final DateTime createdAt;
  final bool isRead;

  Message({
    this.id,
    required this.caseId,
    required this.userName,
    required this.contactInfo,
    required this.textMessage,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'case_id': caseId,
      'user_name': userName,
      'contact_info': contactInfo,
      'text_message': textMessage,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_read': isRead ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      caseId: map['case_id'],
      userName: map['user_name'],
      contactInfo: map['contact_info'],
      textMessage: map['text_message'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isRead: map['is_read'] == 1,
    );
  }
}
