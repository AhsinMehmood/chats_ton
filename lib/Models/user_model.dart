class UserModel {
  final String phoneNumber;
  final String imageUrl;
  final String dateOfBirth;
  final String firstName;
  final String lastName;
  final String countryCode;

  UserModel(
      {required this.phoneNumber,
      required this.imageUrl,
      required this.dateOfBirth,
      required this.countryCode,
      required this.firstName,
      required this.lastName});
  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
        phoneNumber: map['phoneNumber'] ?? '',
        countryCode: map['countryCode'] ?? '+880',
        imageUrl: map['profileImageUrl'] ??
            'https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/logo.png?alt=media&token=79a14d6f-4c93-405f-927d-109e6e4c4c3e',
        dateOfBirth: map['dateOfBirth'] ?? '',
        firstName: map['firstName'] ?? '',
        lastName: map['lastName'] ?? '');
  }
}
