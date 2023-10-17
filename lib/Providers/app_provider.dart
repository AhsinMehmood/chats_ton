import 'package:chats_ton/Models/language_model.dart';
import 'package:chats_ton/l10n/en.dart';
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
}
