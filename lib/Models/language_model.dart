class LanguageModel {
  final String splashTitle;
  final String splashSubtitle;
  final String welcomeBack;
  final String welcomeBackShort;

  final String enterYourNumber;
  final String loginMain;
  final String continueText;
  final String termsOfUse;
  final String privacyPolicy;
  final String verificationCode;
  final String verify;
  final String sendAgain;
  final String skip;
  final String profileDetails;
  final String firstName;
  final String lastName;
  final String chooseBirthdayDate;
  final String confirm;
  final String home;

  LanguageModel({
    required this.splashTitle,
    required this.sendAgain,
    required this.verificationCode,
    required this.verify,
    required this.splashSubtitle,
    required this.welcomeBack,
    required this.welcomeBackShort,
    required this.enterYourNumber,
    required this.loginMain,
    required this.continueText,
    required this.termsOfUse,
    required this.privacyPolicy,
    required this.skip,
    required this.profileDetails,
    required this.firstName,
    required this.lastName,
    required this.chooseBirthdayDate,
    required this.confirm,
    required this.home,
  });
  factory LanguageModel.fromMap(Map<String, dynamic> map) {
    return LanguageModel(
      splashTitle: map['splashTitle'],
      verificationCode: map['verificationCode'],
      verify: map['verify'],
      sendAgain: map['sendAgain'],
      splashSubtitle: map['splashSubtitle'],
      welcomeBack: map['welcomeBack'],
      welcomeBackShort: map['welcomeBackShort'],
      enterYourNumber: map['enterYourNumber'],
      loginMain: map['loginMain'],
      continueText: map['continueText'],
      termsOfUse: map['termsOfUse'],
      skip: map['skip'],
      profileDetails: map['profileDetails'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      chooseBirthdayDate: map['chooseBirthdayDate'],
      confirm: map['confirm'],
      privacyPolicy: map['privacyPolicy'],
      home: map['home'],
    );
  }
}
