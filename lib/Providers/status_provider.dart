import 'dart:io';

import 'package:chats_ton/Models/status_model.dart';
import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusProvider with ChangeNotifier {
  List<StatusModel> _listOfStatus = [];
  List<StatusModel> get listOfStatus => [..._listOfStatus];
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Stream<List<StatusModel>> statusStream() async* {}

  final ImagePicker picker = ImagePicker();

  XFile? _userPickedFile;
  XFile? get userPickedFile => _userPickedFile;
  pickImage(ImageSource imageSource) {
    picker.pickImage(source: imageSource).then((value) {
      _userPickedFile = value;
    });
    notifyListeners();
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> saveStatusImage(File file) async {
    final poiImageRef = storageRef.child("status/${file.path}.jpg");
    await poiImageRef.putFile(file);
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }

  addStatus() async {
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';
    String imageUrl = await saveStatusImage(File(_userPickedFile!.path));
    await _firebaseFirestore.collection('statusUpdate').add({
      'timestamp': FieldValue.serverTimestamp(),
      'contacts': [],
      'views': 0,
      'imageUrl': imageUrl,
      'postedBy': userId,
    });
  }
}
