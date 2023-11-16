import 'package:chats_ton/Providers/app_provider.dart';
import 'package:chats_ton/UI/Pages/otp_page.dart';
import 'package:chats_ton/UI/Widgets/big_button.dart';
import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../Global/color.dart';
import '../../Models/language_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedCountry = '+880';
  TextEditingController phoneNumber = TextEditingController();
  String verificationIds = '';
  int resendTokens = 0;
  PhoneAuthCredential? phoneAuthCredential;
  _handleOtp() async {
    String mobileNumber = '';
    if (phoneNumber.text[0] == '0') {
      mobileNumber = phoneNumber.text.substring(1);
    } else {
      mobileNumber = phoneNumber.text;
    }
    Get.dialog(const LoadingDialog(), barrierDismissible: false);

    await FirebaseAuth.instance
        .verifyPhoneNumber(
          phoneNumber: _selectedCountry + mobileNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // setState(() {
            //   phoneAuthCredential = credential;
            // });
            // Get.offAll(() => OtpPage(
            //       phoneNumber: _selectedCountry + phoneNumber.text.trim(),
            //       verificationId: verificationIds,
            //     ));
          },
          verificationFailed: (FirebaseAuthException e) {
            print(e.toString());
            Get.close(1);
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              verificationIds = verificationId;
              resendTokens = resendToken!;
            });
            Get.close(1);
            Get.to(() => OtpPage(
                  phoneNumber: _selectedCountry + mobileNumber,
                  verificationId: verificationId,
                  countryCode: _selectedCountry,
                ));
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        )
        .then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    final LanguageModel languageModel =
        Provider.of<AppProvider>(context).languages.first;
    AppColor appColor = AppColor();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              Text(
                languageModel.welcomeBack,
                style: GoogleFonts.montserrat(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: appColor.changeColor(color: '252525'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageModel.welcomeBackShort.split('HomePage').first,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appColor.changeColor(color: '252525'),
                    ),
                  ),
                  Text(
                    'Homepage',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appColor.changeColor(color: appColor.purpleColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                languageModel.enterYourNumber,
                style: GoogleFonts.poppins(
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              Text(
                languageModel.loginMain,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                width: Get.width * 0.9,
                height: 57,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: appColor.changeColor(color: 'E8E6EA'),
                ),
                child: Row(
                  children: [
                    CountryCodePicker(
                      onChanged: (CountryCode value) {
                        setState(() {
                          _selectedCountry = value.dialCode!;
                        });
                      },
                      // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                      initialSelection: 'BD',
                      favorite: const ['+880', '+92'],
                      padding: const EdgeInsets.all(0),
                      showFlag: false,
                      showDropDownButton: true,
                      // optional. Shows only country name and flag
                      showCountryOnly: false,
                      // optional. Shows only country name and flag when popup is closed.
                      showOnlyCountryWhenClosed: false,
                      // optional. aligns the flag and the Text left
                      alignLeft: false,
                    ),
                    Expanded(
                        child: TextFormField(
                      controller: phoneNumber,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0000000',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black.withOpacity(0.5),
                          )),
                    ))
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              InkWell(
                onTap: () {
                  if (phoneNumber.text.length > 10 ||
                      phoneNumber.text.isEmpty ||
                      phoneNumber.text.length < 10) {
                    Get.showSnackbar(const GetSnackBar(
                      message: 'A valid phone number is required!',
                      duration: Duration(seconds: 3),
                    ));
                  } else {
                    _handleOtp();
                    // Get.dialog(const LoadingDialog(),
                    //     barrierDismissible: false);
                  }
                  // Get.to(() => OtpPage(
                  //       phoneNumber: _selectedCountry + phoneNumber.text.trim(),
                  //     ));
                },
                child: BigButton(
                    color: appColor.changeColor(color: appColor.purpleColor),
                    text: languageModel.continueText,
                    textColor: Colors.white),
              ),
              const SizedBox(
                height: 170,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageModel.termsOfUse,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: appColor.changeColor(color: appColor.purpleColor),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.2,
                  ),
                  Text(
                    languageModel.privacyPolicy,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: appColor.changeColor(color: appColor.purpleColor),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
