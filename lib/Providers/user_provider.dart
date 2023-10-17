import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/user_model.dart';

class UserProvider with ChangeNotifier {
  final ImagePicker picker = ImagePicker();

  XFile? _userPickedFile;
  XFile? get userPickedFile => _userPickedFile;
  pickImage(ImageSource imageSource) {
    picker.pickImage(source: imageSource).then((value) {
      _userPickedFile = value;
    });
    notifyListeners();
  }

  updateProfile(
      {required String firstName,
      required String lastName,
      required File imageFile,
      required String birthdate}) async {}
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Stream<UserModel> getUserStream() async* {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? 'null';
    if (userId == 'null') {
      yield* firebaseFirestore.collection('users').doc('').snapshots().map(
          (event) => UserModel.fromJson(event.data() as Map<String, dynamic>));
    } else {
      yield* firebaseFirestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromJson(event.data() as Map<String, dynamic>));
    }
  }
}
