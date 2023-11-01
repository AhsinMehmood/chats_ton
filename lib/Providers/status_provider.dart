import 'dart:io';

import 'package:chats_ton/Models/status_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusProvider with ChangeNotifier {
  // List<StatusModel> _listOfStatus = [];
  // List<StatusModel> get listOfStatus => [..._listOfStatus];
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  // final Map<String, List<UserModel>> _groupedContacts = {};
  // Map<String, List<UserModel>> get groupedContacts => _groupedContacts;
  // Stream<List<StatusModel>> statusStream() async* {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   // String userId = sharedPreferences.getString('userId') ?? '';
  //   String phoneNumber = sharedPreferences.getString('phoneNumber') ?? '';

  //   // Use a Stream to continuously listen for changes in Firestore
  //   await for (QuerySnapshot<Map<String, dynamic>> querySnapshot
  //       in _firebaseFirestore
  //           .collection('statusUpdate')
  //           // .where('contacts', arrayContains: phoneNumber)
  //           // .where('timestamp', isLessThan: twentyFourHoursAgo)
  //           .snapshots()) {
  //     print(querySnapshot.docs.length);
  //     // Process the query results and yield the list of StatusModel objects
  //     List<StatusModel> statusModels = querySnapshot.docs
  //         .map((doc) => StatusModel.fromJson(
  //               doc.data(),
  //             ))
  //         .toList();
  //     yield statusModels;
  //   }
  // }

  final ImagePicker picker = ImagePicker();
  bool _uploading = false;
  bool get uploading => _uploading;
  changeUploading(bool value) {
    _uploading = value;
    notifyListeners();
  }

  XFile? _userPickedFile;
  XFile? get userPickedFile => _userPickedFile;
  pickImage(ImageSource imageSource, List contacts) {
    picker.pickImage(source: imageSource).then((value) {
      if (value != null) {
        changeUploading(true);
        _userPickedFile = value;
        addStatus(contacts);
      }

      // print(value!.mimeType! + 'sdasds');
    });

    notifyListeners();
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> saveStatusImage(File file) async {
    final poiImageRef = storageRef.child("status/${file.path}");
    await poiImageRef.putFile(file);
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }

  Stream<List<UserModel>> statusStream(String phoneNumber) {
    return _firebaseFirestore
        .collection('users')
        .where('contacts', arrayContains: phoneNumber)
        .snapshots()
        .map((event) =>
            event.docs.map((e) => UserModel.fromJson(e.data(), e.id)).toList());
  }

  addStatus(List contacts) async {
    // Get.dialog(const LoadingDialog(), barrierDismissible: false);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';
    String imageUrl = await saveStatusImage(File(_userPickedFile!.path));
    await _firebaseFirestore.collection('users').doc(userId).update({
      'statusList': FieldValue.arrayUnion([
        {
          'timestamp': DateTime.now().toIso8601String(),
          'contacts': contacts,
          'imageUrl': imageUrl,
          'postedBy': userId,
          'storyType': 'image',
          'viewerIds': [],
        }
      ]),
    }).then((value) {
      changeUploading(false);
      // Get.close(1);
    });
  }

  removeStatus(StatusModel statusModel) async {
    Map toRemove = {
      'imageUrl': statusModel.imageUrl,
      'contacts': statusModel.contactsList,
      'postedBy': statusModel.postedById,
      'viewerIds': statusModel.viewerIds,
      'timestamp': statusModel.timestamp,
      // 'views': 1,
    };
    print(toRemove);
    await _firebaseFirestore
        .collection('users')
        .doc('eopJDE7ErGenhol60WfwRCH0rpF3')
        .update({
      'statusList': FieldValue.arrayRemove([
        toRemove,
      ])
    }).then((value) {
      print('oject');
    });

    notifyListeners();
  }

  getStatusUpdate() async* {}
}
