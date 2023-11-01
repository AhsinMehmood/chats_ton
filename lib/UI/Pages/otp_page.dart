import 'dart:async';

import 'package:chats_ton/Global/var.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/contacts_provider.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/Pages/tabs_page.dart';
import 'package:chats_ton/UI/Widgets/arrow_botton.dart';
import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as stf;
import 'package:stream_video_flutter/stream_video_flutter.dart' as stv;

import '../../Global/color.dart';
import '../../Models/language_model.dart';
import '../../Providers/app_provider.dart';
import 'edit_profile_page.dart';

class OtpPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String countryCode;
  const OtpPage(
      {super.key,
      required this.phoneNumber,
      required this.verificationId,
      required this.countryCode});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  int timeSeconds = 60;
  String verificationId = '';
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(microseconds: 10)).then((value) {
      setState(() {
        verificationId = widget.verificationId;
      });
      doseconds();
    });
  }

  Timer? timer;
  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  doseconds() async {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeSeconds > 0) {
        setState(() {
          timeSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
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
                height: 40,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Get.back();
                    // doseconds();
                  },
                  child: ArrowButton(
                      color: appColor.changeColor(color: appColor.purpleColor),
                      icon: 'assets/arrow_left.svg'),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '00:$timeSeconds',
                      style: GoogleFonts.poppins(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      languageModel.verificationCode,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTextBox(0),
                        _buildTextBox(1),
                        _buildTextBox(2),
                        _buildTextBox(3),
                        _buildTextBox(4),
                        _buildTextBox(5),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              _buildKeyboard(),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 56,
                width: Get.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: appColor.changeColor(color: appColor.purpleColor),
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (timeSeconds > 0) {
                        } else {
                          resendOtp();
                        }
                      },
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Container(
                        height: 56,
                        width: Get.width * 0.4,
                        decoration: BoxDecoration(
                            color: appColor.changeColor(
                                color: appColor.purpleColor),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(30),
                            )),
                        child: Center(
                          child: Text(
                            languageModel.sendAgain,
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        verifyOtp();
                      },
                      child: SizedBox(
                        height: 56,
                        width: Get.width * 0.35,
                        child: Center(
                          child: Text(
                            languageModel.verify,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appColor.changeColor(
                                  color: appColor.purpleColor),
                            ),
                          ),
                        ),
                        // color: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String text = '';

  void _onKeyboardTap(String value) {
    if (text.length < 5) {
      setState(() {
        text = text + value;
      });
    } else {
      if (text.length == 6) {
      } else {
        setState(() {
          text = text + value;
        });
      }
    }
  }

  verifyOtp() async {
    print(verificationId);
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: text);
    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: true);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((UserCredential userCredential) async {
        if (userCredential.additionalUserInfo!.isNewUser) {
          createNewUser(userCredential);
        } else {
          final chatClient = stf.StreamChat.of(context).client;
          DocumentSnapshot<Map<String, dynamic>> userCurrent =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .get();
          UserModel userModel =
              UserModel.fromJson(userCurrent.data()!, userCurrent.id);
          sharedPreferences.setString(
              'userName', '${userModel.firstName} ${userModel.lastName}');
          sharedPreferences.setString('imageUrl', userModel.imageUrl);
          sharedPreferences.setString('userId', userCredential.user!.uid);
          sharedPreferences.setString('phoneNumber', widget.phoneNumber);
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

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCurrent.id)
              .update({'pushToken': token});
          await Future.delayed(const Duration(seconds: 1));
          // ignore: use_build_context_synchronously

          // final UserModel user = Provider.of(context, listen: false);

          chatClient.disconnectUser();
          stv.StreamVideo.reset(disconnect: true);
          chatClient.closeConnection();

          // log(i!);

          String userToken = UserProvider().createToken(
              '9vk52k6wjnj6', sharedPreferences.getString('userId')!);

          await chatClient.connectUser(
            stf.User(
              id: sharedPreferences.getString('userId')!,
              name: sharedPreferences.getString('userName'),
              // role: 'own',
              lastActive: DateTime.now(),
              image: sharedPreferences.getString('imageUrl'),

              // online: user.activeStatus == 'Active' ? true : false,
            ),
            userToken,
          );
          await chatClient.updateUser(
              stf.User(id: sharedPreferences.getString('userId')!, extraData: {
            'pushToken': token,
          }));

          stv.StreamVideo(
            chatApiKey,
            user: stv.User(
              info: stv.UserInfo(
                id: sharedPreferences.getString('userId')!,
                name:
                    sharedPreferences.getString('userName') ?? 'Ahsan Mehmood',
                image: sharedPreferences.getString('imageUrl'),
                // extraData: {
                //   'pushToken': token,
                // },
              ),

              // online: user.activeStatus == 'Active' ? true : false,
            ),
            userToken: userToken,
          );

          ContactsProvider().requestContactPermission();
          Get.close(1);
          Get.offAll(() => const TabsPage());
        }
      });
    } catch (e) {
      Get.close(1);
      print(e);
      Get.showSnackbar(const GetSnackBar(
        message: 'Invalid OTP',
        duration: Duration(seconds: 3),
      ));
    }
    // if (credential.token != null) {
    // } else {}
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  createNewUser(UserCredential userCredential) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      String? token = await messaging.getToken();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'userId': userCredential.user!.uid,
        'phoneNumber': widget.phoneNumber,
        'countryCode': widget.countryCode,
        'pushToken': token,
        'createdAt': DateTime.now().toIso8601String(),
      }).then((value) {
        Get.close(1);
        sharedPreferences.setString('userId', userCredential.user!.uid);
        sharedPreferences.setString('phoneNumber', widget.phoneNumber);
        Get.offAll(() => const CompleteProfilePage());
      });
    } catch (e) {
      Get.close(1);
    }
  }

  _buildTextBox(int position) {
    AppColor appColor = AppColor();
    try {
      return Card(
        shadowColor: appColor.changeColor(color: appColor.purpleColor),
        color: appColor.changeColor(color: appColor.purpleColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 60,
          width: 45,
          decoration: BoxDecoration(
              color: appColor.changeColor(color: appColor.purpleColor),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: appColor.changeColor(color: appColor.purpleColor),
              )),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              text[position],
              style: GoogleFonts.poppins(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      );
    } catch (e) {
      return Card(
        shadowColor: appColor.changeColor(color: appColor.purpleColor),
        color: appColor.changeColor(color: appColor.purpleColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          height: 60,
          width: 45,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: appColor.changeColor(color: appColor.purpleColor),
              )),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              '0',
              style: GoogleFonts.poppins(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: appColor
                    .changeColor(color: appColor.purpleColor)
                    .withOpacity(0.5),
              ),
            ),
          ),
        ),
      );
    }
  }

  _buildKeyboard() {
    return Container(
      height: 290,
      width: Get.width,
      // color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buttonBuild('1', () {
                _onKeyboardTap('1');
              }),
              _buttonBuild('2', () {
                _onKeyboardTap('2');
              }),
              _buttonBuild('3', () {
                _onKeyboardTap('3');
              }),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buttonBuild('4', () {
                _onKeyboardTap('4');
              }),
              _buttonBuild('5', () {
                _onKeyboardTap('5');
              }),
              _buttonBuild('6', () {
                _onKeyboardTap('6');
              }),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buttonBuild('7', () {
                _onKeyboardTap('7');
              }),
              _buttonBuild('8', () {
                _onKeyboardTap('8');
              }),
              _buttonBuild('9', () {
                _onKeyboardTap('9');
              }),
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // _buttonBuild('7'),
              const SizedBox(
                width: 102,
                height: 36,
              ),
              _buttonBuild('0', () {
                _onKeyboardTap('0');
              }),
              InkWell(
                onTap: () {
                  if (text.isNotEmpty) {
                    setState(() {
                      text = text.substring(0, text.length - 1);
                    });
                  }
                },
                child: SizedBox(
                  width: 102,
                  height: 36,
                  child: SvgPicture.asset(
                    'assets/delete.svg',
                    height: 23,
                    width: 17,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  _buttonBuild(String text, Function onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 102,
        height: 36,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
                fontSize: 24, fontWeight: FontWeight.w400, color: Colors.black),
          ),
        ),
      ),
    );
  }

  resendOtp() async {
    setState(() {
      text = '';
    });
    Get.dialog(const LoadingDialog(), barrierDismissible: true);

    await FirebaseAuth.instance
        .verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('Verification Completed');
        // Get.offAll(() => OtpPage(
        //       phoneNumber: widget.phoneNumber,
        //       verificationId: verificationIds,
        //     ));
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification Failded $e');
        Get.close(1);
      },
      codeSent: (String verificationIda, int? resendToken) {
        print('Code Sent');
        Get.close(1);

        setState(() {
          timeSeconds = 60;

          verificationId = verificationIda;
        });

        doseconds();

        // Get.offAll(() => OtpPage(
        //       phoneNumber: widget.phoneNumber,
        //       verificationId: verificationId,
        //     ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code Autoretrival Time out');
      },
    )
        .then((value) {
      // Get.close(1);
    });
  }
}
