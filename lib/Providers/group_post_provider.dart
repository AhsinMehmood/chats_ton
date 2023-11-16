import 'dart:io';

import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class GroupPostProvider with ChangeNotifier {
  final ImagePicker picker = ImagePicker();
  final databaseReference = FirebaseDatabase.instance.ref();

  // @override
  // void onInit() {
  //   // : implement onInit
  //   super.onInit();
  // }

  XFile? _userPickedFile;
  XFile? get userPickedFile => _userPickedFile;
  pickImage(ImageSource imageSource) async {
    picker.pickImage(source: imageSource).then((value) async {
      CroppedFile? imageCropper =
          await ImageCropper.platform.cropImage(sourcePath: value!.path);
      if (imageCropper != null) {
        _userPickedFile = XFile(imageCropper.path);
        notifyListeners();
      }
    });
  }

  clearImage() {
    _userPickedFile = null;
    notifyListeners();
  }

  saveGroupPost(
      String description, File imageFile, String userId, String groupId) async {
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    String imageUrl = await saveGroupPostImage(imageFile);
    await FirebaseFirestore.instance.collection('groupPosts').add({
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'groupIds': [groupId],
      'userId': userId,
      'description': description,
      'likedBy': [],
      'comments': [],
    }).then((value) {
      _userPickedFile = null;
      notifyListeners();
      Get.close(2);
    });
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> saveGroupPostImage(File file) async {
    final poiImageRef = storageRef.child("images/${file.path}");
    await poiImageRef.putFile(file);
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }

  likePost(String postId, String userId) {
    // if()
    FirebaseFirestore.instance.collection('groupPosts').doc(postId).update({
      'likedBy': FieldValue.arrayUnion([userId]),
    });
  }

  disLikePost(String postId, String userId) {
    FirebaseFirestore.instance.collection('groupPosts').doc(postId).update({
      'likedBy': FieldValue.arrayRemove([userId]),
    });
  }
}
