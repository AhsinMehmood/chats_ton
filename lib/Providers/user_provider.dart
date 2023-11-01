import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_jwt_token/dart_jwt_token.dart';
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
      notifyListeners();
    });
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
          (event) => UserModel.fromJson(
              event.data() as Map<String, dynamic>, event.id));
    } else {
      yield* firebaseFirestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromJson(
              event.data() as Map<String, dynamic>, event.id));
    }
  }

  String createToken(String apiKey, String userId) {
    Map payload = {"api_key": apiKey, "user_id": userId};
    Map<String, dynamic> headers = {'alg': 'HS256', 'typ': 'JWT'};
    SecretKey key = SecretKey(
        'yhry4hz9ux9y6mpu9dfjzrn29nqhrzah7ce3h2t5thd8w8tvj4f3x9c86y5e3y2e');
    String token = "";
    final jwt = JWT(payload, header: headers);
    token = jwt.sign(key);
    return token;
  }
}

const String chatApiKey = '9vk52k6wjnj6';
