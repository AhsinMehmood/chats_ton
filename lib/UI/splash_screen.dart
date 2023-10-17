// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/language_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/app_provider.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/UI/Pages/login_page.dart';
import 'package:chats_ton/UI/Pages/tabs_page.dart';
import 'package:chats_ton/UI/Widgets/arrow_botton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/edit_profile_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4)).then((value) {
      checkUserLogin();
    });
  }

  checkUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';
    if (userId.isNotEmpty) {
      setState(() {
        _loading = false;
      });

      final UserModel userModel =
          Provider.of<UserModel>(context, listen: false);

      await Provider.of<ContactsProvider>(context, listen: false)
          .getContacts(userModel);
      Get.offAll(() => const TabsPage());
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LanguageModel languageModel =
        Provider.of<AppProvider>(context).languages.first;
    AppColor app = AppColor();
    return Scaffold(
      backgroundColor: app.changeColor(color: app.purpleColor),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Flutter
            Center(child: SvgPicture.asset('assets/logo.svg')),
            const SizedBox(
              height: 150,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageModel.splashTitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      languageModel.splashSubtitle,
                      style: GoogleFonts.montserrat(
                        fontSize: 21,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 80,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  if (!_loading) {
                    if (Platform.isMacOS) {
                      FirebaseAuth.instance
                          .signInAnonymously()
                          .then((UserCredential userCredential) {
                        if (userCredential.additionalUserInfo!.isNewUser) {
                          createNewUser(userCredential);
                        } else {
                          sharedPreferences.setString(
                              'userId', userCredential.user!.uid);
                          Get.close(1);
                          Get.offAll(() => const TabsPage());
                        }
                      });
                    } else {
                      Get.offAll(() => const LoginPage());
                    }
                  }
                },
                child: const ArrowButton(
                    color: Colors.white, icon: 'assets/arrow_right.svg'),
              ),
            )
          ],
        ),
      ),
    );
  }

  createNewUser(UserCredential userCredential) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'userId': userCredential.user!.uid,
        'phoneNumber': 'widget.phoneNumber',
        'createdAt': DateTime.now().toIso8601String(),
      }).then((value) {
        Get.close(1);
        sharedPreferences.setString('userId', userCredential.user!.uid);

        Get.offAll(() => const CompleteProfilePage());
      });
    } catch (e) {
      Get.close(1);
    }
  }
}
