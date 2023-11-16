import 'dart:convert';

import 'package:chats_ton/Models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class VoiceCallProvider with ChangeNotifier {
  String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  Map<String, String>? header = {
    "Content-Type": "application/json",
    "Authorization":
        "key=AAAAU8rY3eI:APA91bF1lU6paj9_JCO6bcE4iFBn-3zDS58_5KE7pv9fbGGjbAsoVAj1Xzntbe1C8gEnxmGXR-lioDBsJyDTxRGL4FdbdLLlKx_dqQ1YR4PbvID-aMFY4gHTZJsz9w6ucK60LXVfixh-"
  };
  Future<void> sendCallNotification(
      {required String recipientToken,
      required UserModel userModel,
      required String messageId,
      required String callId,
      required String callType}) async {
    // print(recipientToken);
    String token = recipientToken;

    final payload = jsonEncode({
      "notification": {
        "body": '${userModel.firstName} ${userModel.lastName} Called',
        "time": ""
      },
      'data': {
        'type': 'call',
        'callerId': userModel.userId, // Voice or video call
        'callerName': '${userModel.firstName} ${userModel.lastName}',
        'callerImageUrl': userModel.imageUrl,
        'callerPhoneNumber': userModel.phoneNumber,
        'channelId': callId,
        'messageId': messageId,
        'callType': callType,

        // Recipient's FCM token
      },
      "to": token,
    });
    // print(message.toString());
    http.Response response =
        await http.post(Uri.parse(fcmUrl), headers: header, body: payload);
    print(response.body);
  }

  Future<void> sendMessageNotification(
      {required String recipientToken,
      required UserModel userModel,
      required String message,
      required String groupId,
      required String messageType,
      required String messageId,
      String convType = 'oneToOne'}) async {
    // print(recipientToken);
    String token = recipientToken;

    final payload = jsonEncode({
      "notification": {
        "body": message,
        // "time": DateTime.now().toIso8601String(),
        'title': '${userModel.firstName} ${userModel.lastName} sent a message'
      },
      'data': {
        'type': 'message',
        'senderId': userModel.userId, // Voice or video call
        'senderName': '${userModel.firstName} ${userModel.lastName}',
        'senderImageUrl': userModel.imageUrl,
        'senderPhone': userModel.phoneNumber,
        'groupId': groupId,
        'convType': convType,
        'messageType': messageType,
        "messageId": messageId,

        // Recipient's FCM token
      },
      "to": token,
    });
    // print(message.toString());
    http.Response response =
        await http.post(Uri.parse(fcmUrl), headers: header, body: payload);
    print(response.body);
  }

  initiateCall(
    String callType,
    UserModel currentUser,
    UserModel receiverUser,
  ) async {
    await FirebaseFirestore.instance.collection('calls').add({
      'callType': callType,
      'receptientsId': [currentUser.userId, receiverUser.userId],
      'dateTime': DateTime.now().toIso8601String(),
      'callState': 'Calling',
      'callDuration': 0,
    }).then((value) async {
      // await Future.delayed(const Duration(seconds: 5));
      // await sendCallNotification(
      //         currentUser.pushToken, currentUser, value.id, callType)
      //     .then((lue) {
      //   // Get.to(() => VideoCallPage(
      //   //       secondUser: receiverUser.userId,
      //   //       callId: value.id,
      //   //     ));
      // });
    });
  }

  updateCallMessage(String callId, String callStatus) async {
    FirebaseFirestore.instance.collection('calls').doc(callId).update({
      'callState': callStatus,
      'callDuration': 0,
      'dateTime': DateTime.now().toIso8601String(),
    });
  }
}
