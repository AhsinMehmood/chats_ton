import 'dart:io';

import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/Pages/tabs_page.dart';
import 'package:chats_ton/UI/Widgets/big_button.dart';
import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Global/color.dart';
import '../../Models/language_model.dart';
import '../../Providers/app_provider.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  DateTime? _pickedBirthDate;
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final LanguageModel languageModel =
        Provider.of<AppProvider>(context).languages.first;
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    AppColor appColor = AppColor();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              InkWell(
                onTap: () {
                  Get.offAll(() => const TabsPage());
                },
                child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      languageModel.skip,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color:
                            appColor.changeColor(color: appColor.purpleColor),
                      ),
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                languageModel.profileDetails,
                style: GoogleFonts.poppins(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 160,
                  width: 175,
                  child: Stack(
                    children: [
                      Container(
                        height: 160,
                        width: 156,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            border: Border.all(
                              color: appColor.changeColor(
                                  color: appColor.purpleColor),
                              width: 4,
                            )),
                        child: userProvider.userPickedFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: Image.file(
                                  File(userProvider.userPickedFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          onTap: () {
                            userProvider.pickImage(ImageSource.gallery);
                          },
                          child: Container(
                            height: 53,
                            padding: const EdgeInsets.all(10),
                            width: 53,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                color: appColor.changeColor(
                                    color: appColor.purpleColor),
                                border:
                                    Border.all(color: Colors.white, width: 3)),
                            child: SvgPicture.asset(
                              'assets/camera-2.svg',
                              height: 18,
                              width: 18,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: firstName,
                  decoration: InputDecoration(
                    errorBorder: InputBorder.none,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: appColor.changeColor(
                              color:
                                  'E8E6EA')), // Customize the border color, width, and style
                      borderRadius: const BorderRadius.all(
                          Radius.circular(15)), // Adjust the border radius
                    ),
                    labelText: languageModel.firstName,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    contentPadding:
                        const EdgeInsets.only(left: 40, bottom: 20, top: 20),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextFormField(
                  controller: lastName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    errorBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.only(left: 40, bottom: 20, top: 20),
                    // enabledBorder: InputBorder.none,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: appColor.changeColor(
                              color:
                                  'E8E6EA')), // Customize the border color, width, and style
                      borderRadius: const BorderRadius.all(
                          Radius.circular(15)), // Adjust the border radius
                    ),
                    labelText: languageModel.lastName,
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  showDatePicker(
                          context: context,
                          initialDate: DateTime(2004),
                          firstDate: DateTime(1920),
                          lastDate: DateTime(2008))
                      .then((value) {
                    if (value != null) {
                      setState(() {
                        _pickedBirthDate = value;
                      });
                    }
                  });
                },
                child: Container(
                  height: 57,
                  width: Get.width * 0.8,
                  decoration: BoxDecoration(
                    color: appColor
                        .changeColor(color: appColor.purpleColorDim)
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/Calendar.svg'),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        _pickedBirthDate == null
                            ? languageModel.chooseBirthdayDate
                            : '${_pickedBirthDate!.day} / ${_pickedBirthDate!.month} / ${_pickedBirthDate!.year}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              appColor.changeColor(color: appColor.purpleColor),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 80,
              ),
              InkWell(
                onTap: () {
                  if (userProvider.userPickedFile != null &&
                      firstName.text.trim().isNotEmpty &&
                      lastName.text.trim().isNotEmpty &&
                      _pickedBirthDate != null) {
                    saveUserProfile();
                    // Get.offAll(() => const TabsPage());
                  } else {
                    Get.showSnackbar(const GetSnackBar(
                      message: 'All the fields are required!',
                      duration: Duration(seconds: 3),
                    ));
                  }
                },
                child: BigButton(
                    color: appColor.changeColor(color: appColor.purpleColor),
                    text: languageModel.confirm,
                    textColor: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }

  saveUserProfile() async {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    try {
      Get.dialog(const LoadingDialog(), barrierDismissible: false);
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String imageUrl =
          await savePoiImage(File(userProvider.userPickedFile!.path));
      await FirebaseFirestore.instance
          .collection('users')
          .doc(sharedPreferences.getString('userId'))
          .update({
        'profileImageUrl': imageUrl,
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'dateOfBirth': _pickedBirthDate!.toIso8601String(),
        'updatedAt': DateTime.now(),
      }).then((value) {
        Get.close(1);
        Get.offAll(() => const TabsPage());
      });
    } catch (e) {
      print(e);
      Get.close(1);
    }
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> savePoiImage(File file) async {
    final poiImageRef = storageRef.child("images/${file.path}.jpg");
    await poiImageRef.putFile(file);
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }
}
