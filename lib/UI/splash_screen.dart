// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/language_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/app_provider.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/Pages/login_page.dart';
import 'package:chats_ton/UI/Pages/tabs_page.dart';
import 'package:chats_ton/UI/Widgets/arrow_botton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_story_view/models/user_info.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stv;

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
    Future.delayed(const Duration(seconds: 2)).then((value) {
      checkUserLogin();
    });
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  checkUserLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userId = sharedPreferences.getString('userId') ?? '';
    if (userId.isNotEmpty) {
      await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      String? token = await messaging.getToken();
      log(token!);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'pushToken': token});
      await Future.delayed(const Duration(seconds: 1));
      final chatClient = StreamChat.of(context).client;
      stv.StreamVideo.reset(disconnect: true);
      // final UserModel user = Provider.of(context, listen: false);

      // chatClient.disconnectUser();
      // log(i!);

      String userToken = UserProvider()
          .createToken(chatApiKey, sharedPreferences.getString('userId')!);

      await chatClient.connectUser(
        User(
          id: sharedPreferences.getString('userId')!,
          name: sharedPreferences.getString('userName'),
          lastActive: DateTime.now(),
          image: sharedPreferences.getString('imageUrl'),
          // extraData: {
          //   'pushToken': token,
          // }
          // online: user.activeStatus == 'Active' ? true : false,
        ),
        userToken,
      );
      await chatClient.updateUser(
          User(id: sharedPreferences.getString('userId')!, extraData: {
        'pushToken': token,
      }));
      chatClient.addDevice(token, PushProvider.firebase);
      messaging.onTokenRefresh.listen((token) {
        chatClient.addDevice(token, PushProvider.firebase,
            pushProviderName: 'fb_puch');
      });
      stv.StreamVideo(
        chatApiKey,
        user: stv.User(
          info: stv.UserInfo(
            id: sharedPreferences.getString('userId')!,
            name: sharedPreferences.getString('userName') ?? 'Ahsan Mehmood',
            image: sharedPreferences.getString('imageUrl'),
          ),

          // online: user.activeStatus == 'Active' ? true : false,
        ),
        userToken: userToken,
      );
      // ContactsProvider().requestContactPermission();

      setState(() {
        _loading = false;
      });

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
                      auth.FirebaseAuth.instance
                          .signInAnonymously()
                          .then((auth.UserCredential userCredential) {
                        if (userCredential.additionalUserInfo!.isNewUser) {
                          createNewUser(userCredential);
                        } else {
                          print('object');
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
                child: _loading
                    ? Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2.0,
                        shadowColor: AppColor()
                            .changeColor(color: AppColor().purpleColor),
                        child: Container(
                          height: 52,
                          width: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColor()
                                  .changeColor(color: AppColor().purpleColor),
                            ),
                          ),
                        ),
                      )
                    : const ArrowButton(
                        color: Colors.white, icon: 'assets/arrow_right.svg'),
              ),
            )
          ],
        ),
      ),
    );
  }

  createNewUser(auth.UserCredential userCredential) async {
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
