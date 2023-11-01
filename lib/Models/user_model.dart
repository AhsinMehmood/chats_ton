import 'package:chats_ton/Models/status_model.dart';

class UserModel {
  final String phoneNumber;
  final String imageUrl;
  final String dateOfBirth;
  final String firstName;
  final String lastName;
  final String countryCode;
  final List contacts;
  final String userId;
  final String bio;
  final String activeStatus;
  final String pushToken;
  final List<StatusModel> statusList;

  UserModel(
      {required this.phoneNumber,
      required this.pushToken,
      required this.imageUrl,
      required this.activeStatus,
      required this.dateOfBirth,
      required this.countryCode,
      required this.firstName,
      required this.contacts,
      required this.userId,
      required this.bio,
      required this.statusList,
      required this.lastName});
  factory UserModel.fromJson(Map<String, dynamic> map, String id) {
    List sss = map['statusList'] ?? [];
    List<StatusModel> llls = [];
    for (var element in sss) {
      llls.add(StatusModel.fromJson(element));
    }
    return UserModel(
        phoneNumber: map['phoneNumber'] ?? '',
        pushToken: map['pushToken'] ?? '',
        bio: map['bio'] ?? '',
        activeStatus: map['activeStatus'] ?? 'Away',
        userId: id,
        statusList: llls,
        contacts: map['contacts'] ?? [],
        countryCode: map['countryCode'] ?? '+880',
        imageUrl: map['profileImageUrl'] ??
            'https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/avatar-1577909_1280.png?alt=media&token=c72d3dd0-722f-45b4-81a1-51ceeb06d29a',
        dateOfBirth: map['dateOfBirth'] ?? '',
        firstName: map['firstName'] ?? 'No Name',
        lastName: map['lastName'] ?? '');
  }
}
