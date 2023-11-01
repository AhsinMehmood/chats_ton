class AppSettings {
  final List<String> contactsOnChatsTon;

  AppSettings({required this.contactsOnChatsTon});
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(contactsOnChatsTon: json['appContacs']);
  }
}
