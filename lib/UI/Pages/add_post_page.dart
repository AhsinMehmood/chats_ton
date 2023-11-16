import 'dart:io';

import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/group_model.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/group_post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddGroupPost extends StatefulWidget {
  final GroupModel groupModel;
  const AddGroupPost({super.key, required this.groupModel});

  @override
  State<AddGroupPost> createState() => _AddGroupPostState();
}

class _AddGroupPostState extends State<AddGroupPost> {
  final TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final UserModel userModel = Provider.of<UserModel>(context);
    final GroupPostProvider postProvider =
        Provider.of<GroupPostProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_sharp,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Create New Post',
          style: GoogleFonts.poppins(
            color: AppColor().changeColor(color: AppColor().purpleColor),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor:
                  AppColor().changeColor(color: AppColor().purpleColor),
              elevation: 8.0,
              margin: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 10),
              color: AppColor().changeColor(color: AppColor().purpleColor),
              child: InkWell(
                onTap: () {
                  postProvider.pickImage(ImageSource.gallery);
                },
                child: Container(
                  padding: postProvider.userPickedFile != null
                      ? const EdgeInsets.only(
                          left: 0, right: 0, top: 0, bottom: 0)
                      : const EdgeInsets.only(
                          left: 20, right: 20, top: 25, bottom: 25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:
                        AppColor().changeColor(color: AppColor().purpleColor),
                  ),
                  child: postProvider.userPickedFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(postProvider.userPickedFile!.path),
                            fit: BoxFit.cover,
                            height: 320,
                            width: Get.width,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/upload_post.svg'),
                            Text(
                              'Upload Photo',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextFormField(
                maxLines: 6,
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColor()
                            .changeColor(color: AppColor().purpleColor),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        width: Get.width,
        //    color: Colors.red,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                postProvider.clearImage();
                descriptionController.clear();
              },
              child: Container(
                padding: const EdgeInsets.only(left: 0, right: 0),
                width: Get.width * 0.4,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(31),
                  border: Border.all(
                    color:
                        AppColor().changeColor(color: AppColor().purpleColor),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Discard',
                    style: GoogleFonts.poppins(
                      color:
                          AppColor().changeColor(color: AppColor().purpleColor),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (postProvider.userPickedFile != null) {
                  postProvider.saveGroupPost(
                      descriptionController.text,
                      File(postProvider.userPickedFile!.path),
                      userModel.userId,
                      widget.groupModel.groupChatId);
                } else {
                  Get.showSnackbar(const GetSnackBar(
                    message: 'A picture is required!',
                    duration: Duration(seconds: 2),
                  ));
                }
              },
              child: Container(
                width: Get.width * 0.5,
                padding: const EdgeInsets.only(left: 12, right: 5),
                height: 50,
                decoration: BoxDecoration(
                  color: AppColor().changeColor(color: AppColor().purpleColor),
                  borderRadius: BorderRadius.circular(31),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Upload Post',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(31),
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColor()
                            .changeColor(color: AppColor().purpleColor),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
