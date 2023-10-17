import 'dart:io';

import 'package:chats_ton/Models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class ContactsProvider with ChangeNotifier {
  final List<String> _numbers = ['+923084121347'];
  List<String> get contactNumbers => [..._numbers];
  final List<UserModel> _userContacts = [];
  List<UserModel> get userContacts => [..._userContacts];

  // Request contact permission
  getContacts(UserModel userModel) async {
    if (Platform.isMacOS) {
      for (String element in _numbers) {
        QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
            .instance
            .collection('users')
            .where('phoneNumber', isEqualTo: element)
            .get();
        for (QueryDocumentSnapshot<Map<String, dynamic>> dos in snap.docs) {
          _userContacts.add(UserModel.fromJson(dos.data()));
        }
      }
      print(_userContacts.length);
      notifyListeners();
    } else {
      if (await FlutterContacts.requestPermission()) {
        await FlutterContacts.getContacts().then((value) {
          for (Contact element in value) {
            if (element.phones.first.number.contains('+')) {
              _numbers.add(element.phones.first.number);
            } else {
              _numbers.add(userModel.countryCode + element.phones.first.number);
            }
          }
        });
        for (String element in _numbers) {
          QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
              .instance
              .collection('users')
              .where('phoneNumber', isEqualTo: element)
              .get();
          for (QueryDocumentSnapshot<Map<String, dynamic>> dos in snap.docs) {
            _userContacts.add(UserModel.fromJson(dos.data()));
          }
        }
      } else {
        Get.showSnackbar(const GetSnackBar(
          message: 'Contact permission denied',
          duration: Duration(seconds: 3),
        ));
      }
      notifyListeners();
    }
  }
}
