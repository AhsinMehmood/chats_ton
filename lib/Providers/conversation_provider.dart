import 'dart:developer';
import 'dart:io';
// import 'dart:math';

// import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chats_ton/Models/chats_model.dart';
import 'package:chats_ton/Models/conversation_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:localstore/localstore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';

class ConversationProvider with ChangeNotifier {
  // List<Map<String, dynamic>> sampleConversation = [
  //   {
  //     "conversationId": "1",
  //     "senderId": "user1",
  //     "receiverId": "user2",
  //     "text": "Hello, how are you?",
  //     "messageType": "text",
  //     "timestamp": "2023-10-21T10:00:00Z",
  //     "documentUrl": "",
  //     "videoUrl": "",
  //     "imageUrl": ""
  //   },
  //   {
  //     "conversationId": "2",
  //     "senderId": "user2",
  //     "receiverId": "user1",
  //     "text": "I'm doing well, thanks!",
  //     "messageType": "text",
  //     "timestamp": "2023-10-21T10:05:00Z",
  //     "documentUrl": "",
  //     "videoUrl": "",
  //     "imageUrl": ""
  //   },
  //   {
  //     "conversationId": "3",
  //     "senderId": "user2",
  //     "receiverId": "user1",
  //     "text": "",
  //     "messageType": "audio",
  //     "timestamp": "2023-10-21T10:10:00Z",
  //     "documentUrl":
  //         "https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/videoplayback%20(1).mp3?alt=media&token=c5058fd9-c1b7-4d5c-8b09-2fc8db37b89c",
  //     "videoUrl": "",
  //     "imageUrl": ""
  //   },
  //   {
  //     "conversationId": "4",
  //     "senderId": "user2",
  //     "receiverId": "user1",
  //     "text": "",
  //     "messageType": "image",
  //     "timestamp": "2023-10-21T10:15:00Z",
  //     "documentUrl": "",
  //     "videoUrl": "",
  //     "imageUrl":
  //         "https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/386506467_10228981755635858_847844310146283861_n.jpg?alt=media&token=53744d7a-bdc4-4d14-a1be-0b179b3f7708"
  //   },
  //   {
  //     "conversationId": "5",
  //     "senderId": "user1",
  //     "receiverId": "user2",
  //     "text": "",
  //     "messageType": "video",
  //     "timestamp": "2023-10-21T10:20:00Z",
  //     "documentUrl": "",
  //     "videoUrl":
  //         "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  //     "imageUrl":
  //         "https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/386506467_10228981755635858_847844310146283861_n.jpg?alt=media&token=53744d7a-bdc4-4d14-a1be-0b179b3f7708"
  //   },
  //   {
  //     "conversationId": "6",
  //     "senderId": "user2",
  //     "receiverId": "user1",
  //     "text": "This is another text message.",
  //     "messageType": "text",
  //     "timestamp": "2023-10-21T10:25:00Z",
  //     "documentUrl": "",
  //     "videoUrl": "",
  //     "imageUrl": ""
  //   }
  // ];

  List<ConversationModel> _conversationList = [];
  List<ConversationModel> get conversationList => [..._conversationList];
  // final db = Localstore.instance;

  // getConversation() async {
  //   List<ConversationModel> list = [];

  //   for (Map<String, dynamic> element in sampleConversation) {
  //     list.add(ConversationModel.fromJson(element, element['conversationId']));
  //   }
  //   _conversationList = list;
  //   notifyListeners();
  // }

  // List<GroupedConversation> get groupedConversations =>
  //     groupConversationByDate(_conversationList);
  Map<String, List<ConversationModel>> groupConversationByDate(
      List<ConversationModel> conversationData) {
    final groupedConversations = <String, List<ConversationModel>>{};

    for (final message in conversationData) {
      final messageDate = DateTime.parse(message.timestamp);
      final dateText = _formatDate(messageDate);

      if (!groupedConversations.containsKey(dateText)) {
        groupedConversations[dateText] = [];
      }

      groupedConversations[dateText]!.add(message);
    }

    return groupedConversations;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // PlayerController playingMusicController = PlayerController();

  // addController(PlayerController controller) {
  //   playingMusicController = controller;
  // }

  pausePlayer() {
    // playingMusicController.pausePlayer();
  }

  final List<ChatsModel> _chatsList = [];
  List<ChatsModel> get chats => [..._chatsList];
  void addChats(ChatsModel chatsModels) {
    // _chatsList.clear();
    if (_chatsList.contains(chatsModels)) {
      _chatsList.remove(chatsModels);
    } else {
      _chatsList.add(chatsModels);
    }

    notifyListeners();
  }

  void sendMediaMessage(
    String senderId,
    String reciverId,
    String chatId,
  ) async {
    ImagePicker imagePicker = ImagePicker();
    imagePicker.pickMedia().then((value) async {
      if (value != null) {
        log(value.path);
        log(lookupMimeType(value.path)!.split('/')[0]);
        if (lookupMimeType(value.path)!.split('/')[0] == 'video') {
          Map<String, dynamic> messageData = {
            // "conversationId": "1",
            "senderId": senderId,
            "receiverId": reciverId,
            "text": lookupMimeType(value.path)!.split('/')[0],
            "messageType": lookupMimeType(value.path)!.split('/')[0],
            "timestamp": DateTime.now().toIso8601String(),
            "documentUrl": '',
            "videoUrl": '',
            "imageUrl": '',
          };

          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('conversation')
              .add(messageData)
              .then((messagevalue) async {
            updateChat(reciverId, messagevalue.id, chatId);
            String videoUrl = await saveImageFile(File(value.path));
            // String imageUrl = await saveImageFile(File(file.path));

            _firestore
                .collection('chats')
                .doc(chatId)
                .collection('conversation')
                .doc(messagevalue.id)
                .update({
              'videoUrl': videoUrl,
              // 'imageUrl': imageUrl,
            });
            // print(chatId);
          });
        }
      } else {
        // final filePath = getApplicationDocumentsDirectory();

        Map<String, dynamic> messageData = {
          // "conversationId": "1",
          "senderId": senderId,
          "receiverId": reciverId,
          "text": 'Image',
          "messageType": 'image',
          "timestamp": DateTime.now().toIso8601String(),
          "documentUrl": '',
          "videoUrl": '',
          "imageUrl": '',
        };

        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('conversation')
            .add(messageData)
            .then((messagevalue) async {
          updateChat(reciverId, messagevalue.id, chatId);
          String videoUrl = await saveImageFile(File(value!.path));
          // String imageUrl = await saveImageFile(File(file.path));

          _firestore
              .collection('chats')
              .doc(chatId)
              .collection('conversation')
              .doc(messagevalue.id)
              .update({
            'imageUrl': videoUrl,
          });
          // print(chatId);
        });
      }
    });
  }

  void sendImageMessage(
    String senderId,
    String reciverId,
    String chatId,
  ) async {
    ImagePicker imagePicker = ImagePicker();
    imagePicker.pickImage(source: ImageSource.camera).then((value) async {
      if (value != null) {
        Map<String, dynamic> messageData = {
          // "conversationId": "1",
          "senderId": senderId,
          "receiverId": reciverId,
          "text": 'Image',
          "messageType": "image",
          "timestamp": DateTime.now().toIso8601String(),
          "documentUrl": '',
          "videoUrl":
              'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          "imageUrl": '',
        };
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('conversation')
            .add(messageData)
            .then((messagevalue) async {
          updateChat(reciverId, messagevalue.id, chatId);
          String imageUrl = await saveImageFile(File(value.path));
          _firestore
              .collection('chats')
              .doc(chatId)
              .collection('conversation')
              .doc(messagevalue.id)
              .update({
            'imageUrl': imageUrl,
          });
          // print(chatId);
        });
      }
    });
  }

  void sendVideoMessage(
    String senderId,
    String reciverId,
    String videoFilePath,
    String chatId,
  ) async {
    // String videoUrl = await saveVideoFile(File(videoFilePath));
    Map<String, dynamic> messageData = {
      // "conversationId": "1",
      "senderId": senderId,
      "receiverId": reciverId,
      "text": 'Video',
      "messageType": "video",
      "timestamp": DateTime.now().toIso8601String(),
      "documentUrl": '',
      "videoUrl":
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      "imageUrl":
          "https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/386506467_10228981755635858_847844310146283861_n.jpg?alt=media&token=53744d7a-bdc4-4d14-a1be-0b179b3f7708"
    };
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('conversation')
        .add(messageData)
        .then((value) {
      // print(chatId);
      updateChat(reciverId, value.id, chatId);
    });
  }

  void sendAudioMessage(
    String senderId,
    String reciverId,
    String audioFilePath,
    String chatId,
  ) async {
    String audioUrl = await saveAudioFile(File(audioFilePath));
    Map<String, dynamic> messageData = {
      // "conversationId": "1",
      "senderId": senderId,
      "receiverId": reciverId,
      "text": 'Audio File',
      "messageType": "audio",
      "timestamp": DateTime.now().toIso8601String(),
      "documentUrl": audioUrl,
      "videoUrl": "",
      "imageUrl": ""
    };
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('conversation')
        .add(messageData)
        .then((value) {
      // print(chatId);
      updateChat(reciverId, value.id, chatId);
    });
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> saveImageFile(File file) async {
    final poiImageRef = storageRef.child("images/${file.path}");
    await poiImageRef.putFile(file);
    String imageUrl = await poiImageRef.getDownloadURL();
    print(imageUrl);
    return imageUrl;
  }

  // final storageRef = FirebaseStorage.instance.ref();
  Future<String> saveAudioFile(File file) async {
    final poiImageRef = storageRef.child("images/${file.path}");
    await poiImageRef.putFile(
        file,
        SettableMetadata(
          contentType: "audio/mp3",
        ));
    String imageUrl = await poiImageRef.getDownloadURL();
    print(imageUrl);
    return imageUrl;
  }

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
      'messageStatus': 'sending',
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

  Stream<List<ChatsModel>> chatsStream() async* {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';

    Stream<List<ChatsModel>> chatStream = _firestore
        .collection('chats')
        .where(
          'participants',
          arrayContains: userId,
        )
        .orderBy('updateTime', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot<Map<String, dynamic>> event) async {
      List<ChatsModel> chats = [];

      // Use Future.wait to collect all asynchronous operations
      await Future.wait(event.docs.map((element) async {
        String lastMessageId = element['lastMessageId'] ?? '';
        if (lastMessageId.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> value = await _firestore
              .collection('chats')
              .doc(element.id)
              .collection('conversation')
              .doc(lastMessageId)
              .get();

          DocumentSnapshot<Map<String, dynamic>> snn = await _firestore
              .collection('users')
              .doc(value.data()!['receiverId'])
              .get();

          final message = ChatsModel.fromJson(
            // Populate other message properties
            element.data(),
            element.id,
            ConversationModel.fromJson(
              value.data()!,
              value.id,
            ),
            UserModel.fromJson(snn.data()!, snn.id),
          );

          chats.add(message);
        } else {
          final message = ChatsModel.fromJson(
            // Populate other message properties
            element.data(),
            element.id,
            ConversationModel.fromJson({}, ''),
            UserModel.fromJson({}, ''),
          );
          chats.add(message);
        }
      }));
      chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return chats;
    });

    yield* chatStream;
  }

  // addMessage(Map<String, dynamic> message) async {
  //   final id = db.collection('chats').doc().id;
  //   db.collection('chats').doc(id).set({

  //     'messages': {
  //       "conversationId": "10",
  //       "senderId": "user2",
  //       "receiverId": "user1",
  //       "text": "This is another text message.",
  //       "messageType": "text",
  //       "timestamp": "2023-10-21T10:25:00Z",
  //       "documentUrl": "",
  //       "videoUrl": "",
  //       "imageUrl": ""
  //     },
  //   });

  //   notifyListeners();
  // }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
    }
  }

  clearChats() {
    _chatsList.clear();
    notifyListeners();
  }
}

class GroupedConversation {
  final String date;
  final List<ConversationModel> messages;

  GroupedConversation({required this.date, required this.messages});
}

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   void listenToChatsRealtime(BuildContext context) {
//     final chatsProvider =
//         Provider.of<ConversationProvider>(context, listen: false);

//     _firestore
//         .collection('chats')
//         .orderBy('updateTime')
//         .snapshots()
//         .listen((snapshot) {
//       print(snapshot.docs.length);

//       for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
//         String lastMessageId = doc['lastMessageId'] ?? '';
//         if (lastMessageId.isNotEmpty) {
//           _firestore
//               .collection('chats')
//               .doc(doc.id)
//               .collection('conversations')
//               .doc(lastMessageId)
//               .get()
//               .then((DocumentSnapshot<Map<String, dynamic>> value) {
//             final message = ChatsModel.fromJson(

//                 // Populate other message properties
//                 doc.data(),
//                 doc.id,
//                 ConversationModel.fromJson(
//                     value.data() as Map<String, dynamic>, value.id));

//             // Add the new message to the local list
//             chatsProvider.addChats(message);
//           });
//         } else {
//           final message = ChatsModel.fromJson(

//               // Populate other message properties
//               doc.data(),
//               doc.id,
//               ConversationModel.fromJson({}, ''));

//           // Add the new message to the local list
//           chatsProvider.addChats(message);
//         }
//       }
//     });
//   }

//   void listenToMessagesRealtime(BuildContext context) {
//     final messageProvider =
//         Provider.of<ConversationProvider>(context, listen: false);
//     // _firestore.collection('chats').snapshots().listen((snapshot) {
//     //   for (var doc in snapshot.docs) {
//     //     final message = ConversationModel.fromJson(

//     //         // Populate other message properties
//     //         doc as Map<String, dynamic>);

//     //     // Add the new message to the local list
//     //     messageProvider.addMessage(message);
//     //   }
//     // });
//   }
// }
