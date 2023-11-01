import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final String messageType;
  final String timestamp;
  final String documentUrl;
  String messageStatus;
  final String videoUrl;
  final String imageUrl;
  // AudioPlayer audioPlaying = AudioPlayer();

  ConversationModel(
      {required this.conversationId,
      required this.senderId,
      required this.receiverId,
      required this.messageStatus,
      required this.text,
      required this.messageType,
      required this.timestamp,
      required this.documentUrl,
      required this.videoUrl,
      required this.imageUrl});
  factory ConversationModel.fromJson(Map<String, dynamic> json, String id) {
    return ConversationModel(
      conversationId: id,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      text: json['text'] ?? '',
      messageType: json['messageType'] ?? '',
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      documentUrl: json['documentUrl'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      messageStatus: json['messageStatus'] ?? 'sent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'messageType': messageType,
      'timestamp': timestamp,
      'documentUrl': documentUrl,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'messageStatus': messageStatus,
    };
  }
}
