import 'package:chats_ton/Models/conversation_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatsModel {
  final String chatId;
  final String lastMesageId;
  final List participants;
  final String timestamp;
  final List currentUsernreadMessages;
  final List secondUsernreadMessages;
  final UserModel secondUserData;

  final ConversationModel conversationModel;

  ChatsModel({
    required this.chatId,
    required this.lastMesageId,
    required this.timestamp,
    required this.secondUserData,
    required this.participants,
    required this.conversationModel,
    required this.currentUsernreadMessages,
    required this.secondUsernreadMessages,
  });
  factory ChatsModel.fromJson(Map<String, dynamic> json, String chatId,
      ConversationModel lastMessageData, UserModel secondUsers) {
    // List<Map<String, dynamic>> jsonMessages = json['conversations'] ?? [];
    ConversationModel conversationsModel = lastMessageData;
    UserModel secondUser = secondUsers;

    // for (var i = 0; i < jsonMessages.length; i++) {
    //   conversationsModel.add(ConversationModel.fromJson(jsonMessages[i]));
    // }
    return ChatsModel(
      chatId: chatId,
      secondUserData: secondUser,
      lastMesageId: json['lastMesageId'] ?? '',
      timestamp: json['updateTime'] ?? DateTime.now().toIso8601String(),
      participants: json['participants'] ?? [],
      conversationModel: conversationsModel,
      currentUsernreadMessages: json['currentUsernreadMessages'] ?? [],
      secondUsernreadMessages: json['secondUsernreadMessages'],
    );
  }
}
