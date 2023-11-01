import 'dart:async';

import 'package:chats_ton/Models/conversation_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'voice_call_provider.dart';

class MessageProvider with ChangeNotifier {
  final List<ConversationModel> _conversations = [];
  StreamSubscription? _streamSubscription; // To store the stream subscription

  List<ConversationModel> get conversations => [..._conversations];

  int _limitMessages = 30;
  int get limitMessages => _limitMessages;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void sendTextMessage(
    String senderId,
    String reciverId,
    String text,
    String chatId,
  ) async {
    Map<String, dynamic> messageData = {
      // "conversationId": "1",
      "senderId": senderId,
      "receiverId": reciverId,
      "text": text,
      "messageType": "text",
      "timestamp": DateTime.now().toIso8601String(),
      "documentUrl": "",
      "videoUrl": "",
      "imageUrl": "",
      'messageStatus': 'sent',
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('conversation')
        .add(messageData)
        .then((value) {
      print(chatId);
      updateChat(reciverId, value.id, chatId);
    });
  }

  // void sendCallMessage(
  //   UserModel senderModel,
  //   UserModel receiverModel,
  //   String text,
  //   String chatId,
  //   String messageType,
  //   String callName,
  // ) async {
  //   Map<String, dynamic> messageData = {
  //     // "conversationId": "1",
  //     "senderId": senderModel.userId,
  //     "receiverId": receiverModel.userId,
  //     "text": text,
  //     "messageType": "voice_call",
  //     "timestamp": DateTime.now().toIso8601String(),
  //     "documentUrl": "",
  //     "videoUrl": "",
  //     "imageUrl": "",
  //     'messageStatus': 'Calling',
  //   };

  //   await _firestore
  //       .collection('chats')
  //       .doc(chatId)
  //       .collection('conversation')
  //       .add(messageData)
  //       .then((value) {
  //     print(chatId);

  //     updateChat(receiverModel.userId, value.id, chatId);
  //   });
  // }

  updateChat(
    String secondUserId,
    String lastMessageId,
    String chatid,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';
    _firestore.collection('chats').doc(chatid).update({
      'lastMessageId': lastMessageId,
      'secondUsernreadMessages': FieldValue.arrayUnion([lastMessageId]),
      'currentUsernreadMessages': [],
      'updateTime': DateTime.now().toIso8601String(),
      'participants': [
        userId,
        secondUserId,
      ],
    });
  }

  // Add a message with a sending tag
  void addMessageWithSendingStatus(ConversationModel message) {
    // You can add a unique identifier to the message to track it
    message.messageStatus = 'sending';
    _conversations.insert(
        0, message); // Insert at the beginning for real-time display
    notifyListeners();
  }

  void updateMessageStatus(String messageId, String status) {
    final message = _conversations.firstWhere(
      (message) => message.conversationId == messageId,
      orElse: () => ConversationModel.fromJson({}, ''),
    );

    if (message != null) {
      message.messageStatus = status;
      notifyListeners();
    }
  }

  // Initialize the stream
  void initializeStream(String chatId) {
    _streamSubscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('conversation')
        .orderBy('timestamp', descending: true)
        .limit(_limitMessages)
        .snapshots()
        .listen((event) {
      _conversations.clear(); // Clear previous messages
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in event.docs) {
        _conversations
            .add(ConversationModel.fromJson(element.data(), element.id));
      }
      notifyListeners();
    });
  }

  // Cancel the stream subscription when no longer needed
  void cancelStream() {
    _streamSubscription?.cancel();
  }

  changeMessageLimit() {
    _limitMessages = _limitMessages + 20;
  }
}
