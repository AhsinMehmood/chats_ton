// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chats_ton/Global/color.dart';
import 'package:chats_ton/Models/user_model.dart';
import 'package:chats_ton/Providers/group_provider.dart';
import 'package:chats_ton/Providers/user_provider.dart';
import 'package:chats_ton/UI/Pages/select_members.dart';
import 'package:chats_ton/UI/Widgets/loading_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  String selectedGroupType = 'Team Work';
  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context);
    final GroupProvider groupProvider = Provider.of<GroupProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    AppColor app = AppColor();
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: SvgPicture.asset(
                    'assets/Back_icon.svg',
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Create Group',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Get.to(() => const CreateGroupPage());
                  },
                  icon: const Icon(
                    Icons.add,
                  ),
                  color: Colors.transparent,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                // Align(
                //   alignment: Alignment.center,
                //   child: SizedBox(
                //     height: 160,
                //     width: 175,
                //     child: Stack(
                //       children: [
                //         Container(
                //           height: 156,
                //           width: 156,
                //           decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(200),
                //               border: Border.all(
                //                 color: AppColor()
                //                     .changeColor(color: AppColor().purpleColor),
                //                 width: 4,
                //               )),
                //           child: userProvider.userPickedFile != null
                //               ? ClipRRect(
                //                   borderRadius: BorderRadius.circular(200),
                //                   child: Image.file(
                //                     File(userProvider.userPickedFile!.path),
                //                     fit: BoxFit.cover,
                //                   ),
                //                 )
                //               : const SizedBox.shrink(),
                //         ),
                //         Align(
                //           alignment: Alignment.bottomRight,
                //           child: InkWell(
                //             onTap: () {
                //               userProvider.pickImage(ImageSource.gallery);
                //             },
                //             child: Container(
                //               height: 53,
                //               padding: const EdgeInsets.all(10),
                //               width: 53,
                //               decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.circular(200),
                //                   color: AppColor().changeColor(
                //                       color: AppColor().purpleColor),
                //                   border: Border.all(
                //                       color: Colors.white, width: 3)),
                //               child: SvgPicture.asset(
                //                 'assets/camera-2.svg',
                //                 height: 18,
                //                 width: 18,
                //                 fit: BoxFit.contain,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 30,
                // ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Group Name',
                      style: GoogleFonts.poppins(
                        color: app.changeColor(color: '797C7B'),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 0,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextFormField(
                        maxLines: 2,
                        controller: groupNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Group\nName',
                        ),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                ),
                // const SizedBox(
                //   height: 20,
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(15.0),
                //   child: Align(
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //       'Select Group Type',
                //       style: GoogleFonts.poppins(
                //         color: app.changeColor(color: '797C7B'),
                //         fontSize: 16,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                // ),
                // Container(
                //   height: 60,
                //   width: Get.width,
                //   padding: const EdgeInsets.all(15.0),
                //   child: Align(
                //     alignment: Alignment.centerLeft,
                //     child: ListView(
                //       scrollDirection: Axis.horizontal,
                //       children: [
                //         Card(
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Container(
                //             height: 40,
                //             padding: const EdgeInsets.only(
                //                 left: 10, right: 10, top: 4, bottom: 4),
                //             child: Center(
                //               child: Text(
                //                 'Team Work',
                //                 style: GoogleFonts.poppins(
                //                     color: Colors.black,
                //                     fontSize: 14,
                //                     fontWeight: FontWeight.w500),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Group Admin',
                      style: GoogleFonts.poppins(
                        color: app.changeColor(color: '797C7B'),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(250),
                    child: CachedNetworkImage(
                      imageUrl: userModel.imageUrl,
                      height: 52,
                      width: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    userModel.firstName,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Group Admin',
                    style: GoogleFonts.poppins(
                      color: app.changeColor(color: '797C7B'),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Invite Members',
                      style: GoogleFonts.poppins(
                        color: app.changeColor(color: '797C7B'),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    height: 72,
                    width: Get.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: groupProvider.selectedMembers.length + 1,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => const SelectMembersPage(
                                            appBarText: 'Select Memebrs',
                                          ));
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.all(0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(250),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          right: 0,
                                        ),
                                        height: 72,
                                        width: 72,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(250),
                                            border: Border.all(
                                              color: app.changeColor(
                                                  color: 'CFD3D2'),
                                            )),
                                        child: Center(
                                          child: Icon(
                                            Icons.add,
                                            color: app.changeColor(
                                                color: 'CFD3D2'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final UserModel invitedMemberUser =
                                  groupProvider.selectedMembers[index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Card(
                                  margin: const EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(250),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      right: 0,
                                    ),
                                    height: 72,
                                    width: 72,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(250),
                                        border: Border.all(
                                          color:
                                              app.changeColor(color: 'CFD3D2'),
                                        )),
                                    child: Center(
                                        child: ClipRRect(
                                      borderRadius: BorderRadius.circular(250),
                                      child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          height: 72,
                                          width: 72,
                                          imageUrl: invitedMemberUser.imageUrl),
                                    )),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 90,
                ),
              ],
            ),
          ))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
          onPressed: () async {
            if (groupNameController.text.isNotEmpty) {
              Get.dialog(const LoadingDialog(), barrierDismissible: false);

              String imageUrl =
                  'https://firebasestorage.googleapis.com/v0/b/chats-ton.appspot.com/o/avatar-1577909_1280.png?alt=media&token=c72d3dd0-722f-45b4-81a1-51ceeb06d29a';

              groupProvider
                  .createNewGroup(
                      groupName: groupNameController.text.trim(),
                      groupImageUrl: imageUrl,
                      currentUserId: userModel.userId,
                      context: context)
                  .then((value) {
                // Get.close(2);
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: app.changeColor(color: app.purpleColor),
            maximumSize: Size(Get.width * 0.8, 60),
            minimumSize: Size(Get.width * 0.8, 60),
          ),
          child: Text(
            'Create',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )),
    );
  }

  final storageRef = FirebaseStorage.instance.ref();
  Future<String> savePoiImage(File file) async {
    final poiImageRef = storageRef.child("images/${file.path}.jpeg");
    await poiImageRef.putFile(file);
    String imageUrl = await poiImageRef.getDownloadURL();

    return imageUrl;
  }
}
