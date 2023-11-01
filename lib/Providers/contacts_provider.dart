import 'dart:io';

import 'package:chats_ton/Models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//TODO///

class ContactsProvider with ChangeNotifier {
  List<Contact> _numbers = [
    // '+923084121347',
    // '+8801726592137',
    // '+923140903980',
  ];
  Stream<List<UserModel>> contactsDetailsStream() async* {
    print('object');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> phoneNumbers =
        sharedPreferences.getStringList('contacts') ?? [];

    // final List<String> phoneNumbers = userModel.contacts;
    const batchSize = 30; // Maximum batch size per query

    // Split the phone numbers into batches
    for (int i = 0; i < phoneNumbers.length; i += batchSize) {
      final batch = phoneNumbers.sublist(
          i,
          i + batchSize < phoneNumbers.length
              ? i + batchSize
              : phoneNumbers.length);

      // Perform a Firestore query with the current batch
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', whereIn: batch)
          .get();

      // Process the results of the current batch
      final contactsList = querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();

      // Yield the results of the current batch
      yield contactsList;
    }
  }

  List<Contact> get contactNumbers => [..._numbers];
  List<UserModel> _userContacts = [];
  List<UserModel> get userContacts => [..._userContacts];
  Map<String, List<Contact>> _groupedContacts = {};
  Map<String, List<Contact>> get groupedContacts => _groupedContacts;
  Map<String, List<UserModel>> _groupedContactsUserDetails = {};
  Map<String, List<UserModel>> get groupedContactsUserDetails =>
      _groupedContactsUserDetails;
  // Request contact permission
  Future<bool> requestContactPermission() async {
    bool allowed = await Permission.contacts.request().isGranted;
    if (allowed) {
      await getPhoneNumbers();
      return true;
    } else {
      Get.showSnackbar(const GetSnackBar(
        message: 'Contact permission denied',
        duration: Duration(seconds: 3),
      ));
      return false;
    }
  }

  List<String> _cleanPhone = [];
  List<String> get cleanPhones => _cleanPhone;
  Future getPhoneNumbers() async {
    List<Contact> rawContacts = [];

    Map<String, List<Contact>> groupedContactsStream = {};
    List<String> cleanPhone = [];

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';
    await FastContacts.getAllContacts().then((value) {
      for (Contact element in value) {
        if (element.phones.isNotEmpty) {
          if (element.phones.first.number.isNotEmpty) {
            String phoneNumberWithoutSpace =
                element.phones.first.number.replaceAll(' ', '');
            String phoneNumberWithoutDash =
                phoneNumberWithoutSpace.replaceAll('-', '');
            if (phoneNumberWithoutDash.length >= 10) {
              if (phoneNumberWithoutDash.contains('+')) {
                // print(phoneNumberWithoutDash);
                cleanPhone.add(phoneNumberWithoutDash);
                if (phoneNumberWithoutDash == '+923084121347') {}
                rawContacts.add(element);
              }

              //  print();
            }
          }
        }
      }
      sharedPreferences.setStringList('contacts', cleanPhone);
      for (Contact contact in rawContacts) {
        if (contact.displayName.isNotEmpty) {
          String firstLetter =
              contact.displayName.substring(0, 1).toUpperCase();
          if (!groupedContactsStream.containsKey(firstLetter)) {
            groupedContactsStream[firstLetter] = [];
          }
          groupedContactsStream[firstLetter]!.add(contact);
        }
      }
    });

    _numbers = rawContacts;
    _cleanPhone = cleanPhone;
    _groupedContacts = groupedContactsStream;
    // print(_numbers.length);
    notifyListeners();
    await getContactDetailsFromFirestore();
  }

  Future getContactDetailsFromFirestore() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userPhone = sharedPreferences.getString('phoneNumber') ?? '';
    String userId = sharedPreferences.getString('userId') ?? '';

    List<UserModel> _userContact = [];
    List<String> rawContacts = _cleanPhone;
    rawContacts.removeWhere((phoneNumber) => phoneNumber == userPhone);
    const batchSize = 30;
    List<String> notFoundNumbers = [];
    List<Contact> filterContacts = [];
    Map<String, List<UserModel>> groupedContactsUserDetailsLocal = {};

    for (int i = 0; i < rawContacts.length; i += batchSize) {
      final batch = rawContacts.sublist(
          i,
          i + batchSize < rawContacts.length
              ? i + batchSize
              : rawContacts.length);

      // Query Firestore for each batch.
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', whereIn: batch)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final userAccount = UserModel.fromJson(doc.data(), doc.id);
        _userContact.add(userAccount);
      } else {
        final foundNumbers =
            query.docs.map((doc) => doc['phoneNumber'].toString()).toSet();
        final batchNotFoundNumbers =
            batch.where((number) => !foundNumbers.contains(number)).toList();
        notFoundNumbers.addAll(batchNotFoundNumbers);
        filterContacts = _numbers
            .where((element) =>
                notFoundNumbers.contains(element.phones.first.number))
            .toList();
      }
    }

    for (UserModel userContactDBDetails in _userContact) {
      if (userContactDBDetails.firstName.isNotEmpty) {
        String firstLetter =
            userContactDBDetails.firstName.substring(0, 1).toUpperCase();
        if (!groupedContactsUserDetailsLocal.containsKey(firstLetter)) {
          groupedContactsUserDetailsLocal[firstLetter] = [];
        }
        groupedContactsUserDetailsLocal[firstLetter]!.add(userContactDBDetails);
      }
    }
    // Extract the keys and sort them
    List<String> sortedKeys = groupedContactsUserDetailsLocal.keys.toList();
    sortedKeys.sort();

// Create a new map with sorted keys and sorted UserModel values
    Map<String, List<UserModel>> sortedMap = {};
    for (String key in sortedKeys) {
      List<UserModel> users = groupedContactsUserDetailsLocal[key]!;
      users.sort(
          (a, b) => a.firstName.compareTo(b.firstName)); // Sort by first name
      sortedMap[key] = users;
    }
    List<String> listToUpdate = [];
    for (var element in _userContact) {
      listToUpdate.add(element.phoneNumber);
    }
    sharedPreferences.setStringList('contacts', listToUpdate);

    sharedPreferences.setStringList('contacts', listToUpdate);
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'contacts': FieldValue.arrayUnion(listToUpdate)});

    _numbers = filterContacts;
    _userContacts = _userContact;
    _groupedContactsUserDetails = sortedMap;
    notifyListeners();
  }

  getContacts() async {
    try {
      if (Platform.isMacOS) {
        // getContactDetailsFromFirestore();
      } else {
        requestContactPermission();
      }
    } catch (e) {
      print(e);
    }
  }
}
