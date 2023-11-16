import 'dart:async';
import 'dart:io';

import 'package:chats_ton/Providers/voice_call_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

import '../Models/group_model.dart';
import '../Models/user_model.dart';
import '../UI/Pages/group_message_page.dart';

class GroupController with ChangeNotifier {
  final List<GroupModel> groups = [];
}

class GroupService with ChangeNotifier {
  final DatabaseReference _groupRef =
      FirebaseDatabase.instance.ref().child('groups');

  createNewGroup(
      {required String groupName,
      required String currentUserId,
      required String groupImageUrl,
      required UserModel currentUserModel,
      required List<UserModel> memebrIds}) async {
    DatabaseEvent event = await _groupRef.once();
    int groupId = 1;
    if (event.snapshot.exists) {
      groupId = event.snapshot.children.length + 1;
    }
    Map<dynamic, dynamic> membersMap = {};
    Map<dynamic, dynamic> mutedUsersMap = {};

    for (UserModel element in memebrIds) {
      membersMap[element.userId] = {
        'lastReadTimestamp': getCurrentTimestamp(),
        "role": 'Group Member',
        "member": true,
        'invitePending': true,
        'isCreator': false,
      };
      membersMap[currentUserId] = {
        'lastReadTimestamp': getCurrentTimestamp(),
        "role": 'Group Admin',
        "member": true,
        'invitePending': false,
        'isCreator': true,
      };

      mutedUsersMap[element.userId] = true;
      // mutedUsersMap[currentUserId] = true;
    }
    DatabaseReference newGroupRef =
        FirebaseDatabase.instance.ref().child('groups').push();

    await newGroupRef.set({
      "groupName": groupName,
      "groupImage": groupImageUrl,
      "description": 'Demo Description',
      "groupChatId": groupId.toString(),
      "members": membersMap,
      "mutedUsers": mutedUsersMap,
    });
    Map<String, dynamic> initialMessage = {
      "senderId": "senderUserId1",
      "text":
          "${currentUserModel.firstName} ${currentUserModel.lastName} created this group",
      "timestamp": getCurrentTimestamp(),
      "status": "sent",
      'messageType': 'system',
    };

    DatabaseReference messagesRef = newGroupRef.child("messages").push();
    await messagesRef.set(initialMessage);
    Get.close(2);
    // Get.to(()=> GroupChannelPage());
  }

  Future<String> sendMessage(
      String groupId,
      String text,
      String userId,
      String messageType,
      List<UserModel> members,
      UserModel userModel,
      GroupModel groupData) async {
    DatabaseReference messagesRef = FirebaseDatabase.instance
        .ref()
        .child('groups/$groupId/messages')
        .push();
    Map<String, dynamic> initialMessage = {
      "senderId": userId,
      "text": text,
      'messageType': messageType,
      "timestamp": getCurrentTimestamp(),
      "status": "sent",
      "readByUserIds": [userId],
    };
    await messagesRef.set(initialMessage).then((value) async {
      for (UserModel user in members) {
        if (groupData.mutedUsers[user.userId] == false &&
            user.userId != userId) {
          VoiceCallProvider().sendMessageNotification(
              recipientToken: user.pushToken,
              userModel: userModel,
              message: text,
              groupId: groupId,
              messageType: messageType,
              messageId: messagesRef.key!,
              convType: 'group');
        }
      }
      // await Future.delayed(const Duration(seconds: 4));
    });
    return messagesRef.key!;
  }

  Stream<List<GroupModel>> getGroupListStream(String userId) {
    return _groupRef
        .orderByChild('members/$userId/member')
        .equalTo(true)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return <GroupModel>[];
      }

      final Map<dynamic, dynamic> groupData =
          event.snapshot.value as Map<dynamic, dynamic>;
      // print(groupData.values.first['messages']);
      final List<GroupModel> groups = [];

      groupData.forEach((key, data) {
        final group = GroupModel.fromMap(key, data);
        groups.add(group);
      });

      return groups;
    }).handleError((errors) {
      print(errors);
    });
  }

  void updateLastReadTimestamp(String groupChatId, String userId) {
    final DatabaseReference groupRef =
        FirebaseDatabase.instance.ref().child('groups').child(groupChatId);

    groupRef
        .child('members/$userId/lastReadTimestamp')
        .set(getCurrentTimestamp())
        .catchError((error) {
      debugPrint('Failed to update LastReadTimestamp: $error');
    });
  }

  void acceptInvite(String groupChatId, String userId) {
    final DatabaseReference groupRef =
        FirebaseDatabase.instance.ref().child('groups').child(groupChatId);

    groupRef
        .child('members/$userId/pendingInvite')
        .set(false)
        .catchError((error) {
      debugPrint('Failed to update LastReadTimestamp: $error');
    });
  }

  void leaveGroup(String groupChatId, String userId) {
    final DatabaseReference groupRef =
        FirebaseDatabase.instance.ref().child('groups').child(groupChatId);

    groupRef.child('members/$userId').remove().catchError((error) {
      debugPrint('Failed to update LastReadTimestamp: $error');
    });
  }

  updateMessageStatus(String messageId, String groupId, String status) async {
    await FirebaseDatabase.instance
        .ref()
        .child('groups/$groupId/messages/$messageId/status')
        .set(status);
  }

  deleteMessage(String messageId, String groupId) async {
    await FirebaseDatabase.instance
        .ref()
        .child('groups/$groupId/messages/$messageId')
        .remove();
  }

  int getCurrentTimestamp() {
    final DateTime now = DateTime.now().toLocal();
    final int millisecondsSinceEpoch = now.millisecondsSinceEpoch;
    return (millisecondsSinceEpoch / 1000).round(); // Convert to seconds
  }

  Stream<GroupModel> groupStream(String groupId) {
    final DatabaseReference grouRef =
        FirebaseDatabase.instance.ref().child('groups/$groupId');
    return grouRef.onValue.map((event) => GroupModel.fromMap(
        event.snapshot.key!, event.snapshot.value as Map<dynamic, dynamic>));
  }

  File? _imageFromCamera;
  File? get imageFromCamers => _imageFromCamera;
  selectImageCamera(File file) {
    _imageFromCamera = file;
    notifyListeners();
  }

  clearImageFromCamera() {
    _imageFromCamera = null;
    notifyListeners();
  }

  List<GalleryPickedMedia> _selectedImages = [];
  List<GalleryPickedMedia> get selectedImages => [..._selectedImages];

  // Function to check if an image is selected
  bool isSelected(GalleryPickedMedia image) {
    return _selectedImages.contains(image);
  }

  selectImage(GalleryPickedMedia media) async {
    if (isSelected(media)) {
      print('object');
      // If the image is already selected, remove it
      _selectedImages.remove(media);
    } else {
      // If the image is not selected, add it
      _selectedImages.add(media);
    }

    notifyListeners();
  }

  clearGalleryImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  /// send attatchment message with uploading status
  ///
  ///

  sendMediaMessage(
      String groupId,
      String text,
      String userId,
      String messageType,
      List<UserModel> members,
      UserModel userModel,
      List<GalleryPickedMedia> medias) async {
    _selectedImages.clear();
    _imageFromCamera == null;
    notifyListeners();
    DatabaseReference messagesRef = FirebaseDatabase.instance
        .ref()
        .child('groups/$groupId/messages')
        .push();
    Map<String, dynamic> initialMessage = {
      "senderId": userId,
      "text": 'Sent files',
      'messageType': 'media',
      "timestamp": getCurrentTimestamp(),
      "status": "sending",
      "readByUserIds": [userId],
    };

    await messagesRef.set(initialMessage).then((value) async {
      Future.wait(medias.map((GalleryPickedMedia element) async {
        final thumbnailRef =
            storageRef.child("thumbnail/${element.mediaFile.path}");
        await thumbnailRef.putData(element.thumbnail);
        String thumbnailUrl = await thumbnailRef.getDownloadURL();

        DatabaseReference mediaRef = FirebaseDatabase.instance
            .ref()
            .child('groups/$groupId/messages/${messagesRef.key}/media')
            .push();

        await mediaRef.set({
          'thumbnailUrl': thumbnailUrl,
          'fileUrl': '',
          'type': element.mimeType,
        });
        final fileUpload =
            storageRef.child("filemain/${element.mediaFile.path}");
        await fileUpload.putFile(element.mediaFile);
        String fileUrl = await fileUpload.getDownloadURL();
        await mediaRef.set({
          'thumbnailUrl': thumbnailUrl,
          'fileUrl': fileUrl,
          'type': element.mimeType,
        });
      })).then((value) async {
        await FirebaseDatabase.instance
            .ref()
            .child('groups/$groupId/messages/${messagesRef.key}/status')
            .set('sent');
      });

      // List filesUrls = [];
      // for (File element in _files) {

      //   messageImageRef.putFile(element).snapshotEvents.listen((events) async {
      //     events;
      //     if (events.state == TaskState.success) {
      //       String url = await events.ref.getDownloadURL();
      //       filesUrls.add(url);
      //       print(url);
      //     } else {
      //       double progress = events.bytesTransferred / events.totalBytes;

      //       print('$progress');
      //       await FirebaseDatabase.instance
      //           .ref()
      //           .child('groups/$groupId/messages/${messagesRef.key}')
      //           .update({
      //         'progress': '$progress',
      //         'status': 'sent',
      //         'imageUrls': filesUrls,
      //       });
      //     }
      //   });
      // }
      // for (UserModel user in members) {
      //   VoiceCallProvider().sendMessageNotification(
      //       recipientToken: user.pushToken,
      //       userModel: userModel,
      //       message: text,
      //       groupId: groupId,
      //       messageType: messageType,
      //       messageId: messagesRef.key!,
      //       convType: 'group');
      // }
      // await Future.delayed(const Duration(seconds: 4));
    });
  }

  final storageRef = FirebaseStorage.instance.ref();
  // StreamSubscription<TaskSnapshot> uploadFile(File file) {

  //   // String imageUrl = await messageImageRef.getDownloadURL().then((value) {});
  // }
}

class GalleryPickedMedia {
  final Uint8List thumbnail;
  final File mediaFile;
  final String mimeType;

  GalleryPickedMedia({
    required this.thumbnail,
    required this.mediaFile,
    required this.mimeType,
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GalleryPickedMedia &&
          runtimeType == other.runtimeType &&
          thumbnail == other.thumbnail &&
          mediaFile == other.mediaFile &&
          mimeType == other.mimeType;

  @override
  int get hashCode =>
      thumbnail.hashCode ^ mediaFile.hashCode ^ mimeType.hashCode;
}
