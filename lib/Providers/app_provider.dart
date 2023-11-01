import 'package:chats_ton/Models/app_settings.dart';
import 'package:chats_ton/Models/language_model.dart';
import 'package:chats_ton/l10n/en.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  int _selectedLanguage = 0;

  int get selectedLanguage => _selectedLanguage;
  changeLanguage(int language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  List<Map<String, dynamic>> lang = EN().languages;
  List<LanguageModel> _languages = [
    LanguageModel.fromMap(EN().languages[0]),
  ];
  List<LanguageModel> get languages => [..._languages];
  getLanguage() {
    List<LanguageModel> lam = [];
    for (Map<String, dynamic> element in lang) {
      lam.add(LanguageModel.fromMap(element));
    }
    _languages = lam;
    notifyListeners();
  }

  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  changeTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  Stream<AppSettings> getAppSettingsStream() {
    return FirebaseFirestore.instance
        .collection('appSettings')
        .doc('XKxGqHRdkKoX6WZg9S0f')
        .snapshots()
        .map((event) =>
            AppSettings.fromJson(event.data() as Map<String, dynamic>));
  }
}
